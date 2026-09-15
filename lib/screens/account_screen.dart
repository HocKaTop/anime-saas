import 'package:flutter/material.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.person,
                size:48,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Гость',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Войдите в аккаунт, что бы синхронизировать просмотр',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> LoginScreen(),
            ),);
          },icon: const Icon(Icons.login),
           label: const Text('Войти')
           ),
           const SizedBox(height: 24),
           Card(
            child: Column(
              children: [
                ListTile(
                  leading:const Icon(Icons.history) ,
                  title: const Text("История просмтра"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: (){},
                ),
                const Divider(height: 1),
                ListTile(
                  leading:const Icon(Icons.settings) ,
                  title:const Text ("Настройки") ,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: (){},
                ),
                const Divider(height: 1),
                ListTile(
                  leading:const Icon(Icons.info_outline) ,
                  title: const Text("О приложении"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: (){},
                ),
              ],
            )
           )
        ],
      )
    );
  }
}