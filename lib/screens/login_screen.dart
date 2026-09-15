import 'package:flutter/material.dart';

import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
      ),
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

          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'example@mail.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),

          const SizedBox(height: 16),

          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {},
            child: const Text('Войти'),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            child: const Text('Нет аккаунта? Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}