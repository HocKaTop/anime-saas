import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Данные введены корректно')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),

          Icon(
            Icons.play_circle_fill,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 16),

          Text(
            'Creepy Oleg',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 32),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    hintText: "email@domain.com",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Введите email";
                    }
                    if (!value.contains('@')) {
                      return "Введите корректный email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите пароль";
                    }
                    if (value.length < 6) {
                      return "Длина пароля минимум 6 символов";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton(onPressed: _submit, child: const Text('Войти')),
              ],
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              context.pushNamed(RouteNames.register);
            },
            child: const Text('Нет аккаунта? Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}
