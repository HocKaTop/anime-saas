import 'package:animesaas/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../router_names.dart';
import '../data/auth_api.dart';
import '../data/result.dart';
import '../widgets/profile_settings_panel.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loggingOut = false;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      if (mounted){
        context.read<ProfileModel>().load();
      }
    });
  }

  Future<void> _logout() async {
  if (_loggingOut) return;

  final auth = context.read<AuthApi>();
  final profile = context.read<ProfileModel>();
  final messenger = ScaffoldMessenger.of(context);

  setState(() => _loggingOut = true);
  profile.clear();  

  try {
    final result = await auth.logout();

    if (!mounted) return;

    context.goNamed(RouteNames.login);

    if (result case Err(:final msg)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Вы вышли на этом устройстве. $msg',
          ),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _loggingOut = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();
    final user = profile.user;
    final error = profile.error;

  Widget body;
  if(profile.isLoading || _loggingOut){
    body = const Center(
      child: CircularProgressIndicator(),
    );
  } else if (error !=null) {
    body= ErrorView(message: error, onRetry:()=> profile.load());
  } else if(user == null ){
    body = const Center(
      child: CircularProgressIndicator(),
    );
  } else{
    body = RefreshIndicator(onRefresh: profile.load, child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 24,
            child: Icon(Icons.person_outline, size: 48,),
          ),),
          const SizedBox(height: 16),
          Text(
            user.nickname ?? 'Мой профиль',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height:8),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height:32),
          ProfileSettingsPanel(
            key: ValueKey(user.id),
            nickname: user.nickname,
          ),
          const SizedBox(height: 32,),
          FilledButton.icon(
            onPressed: _logout,
            icon : const Icon(Icons.logout),
            label: const Text('Выйти из аккаунта')
          )
      ],
    ));
  }

    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: body,
    );
  }
}
