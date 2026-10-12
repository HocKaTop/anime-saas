import 'package:animesaas/data/auth_api.dart';
import 'package:animesaas/data/result.dart';
import 'package:animesaas/router_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassowrdController = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassowrdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy){
      return;
    }
    if(!_formKey.currentState!.validate()){
      return;
    }

    setState(() => _busy = true);

    try{
      final result = await context.read<AuthApi>().register(_emailController.text, _passwordController.text);

      if (!mounted) return;

      switch(result){
        case Ok():
        //Register возвращает и сохраняет accessToken
        context.goNamed(RouteNames.browse);
        case Err(:final msg):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted){
        setState(() => _busy=false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            Text(
              'Создать аккаунт',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Введите email";
                }
                if (!value.contains("@")) {
                  return "Введите корректный email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: "Пароль",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password_outlined),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Введите пароль";
                }
                if (value.length < 8 || value.length >128) {
                  return "Длина пароля минимум 6 символов";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPassowrdController,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_)=> _submit(),
              decoration: InputDecoration(
                labelText: "Повторите пароль",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Введите пароль";
                }
                if (value != _passwordController.text) {
                  return "Пароли не совпадают";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy? null: _submit,
              child:  Text(_busy ? 'Создаем аккаунт...' : 'Зарегестрироваться',
              ),
            ),
            TextButton(
              onPressed: _busy ? null : () => context.goNamed(RouteNames.login),
              child: const Text("Уже есть аккаунт? Войти"),
            ),
          ],
        ),
      ),
    );
  }
}
