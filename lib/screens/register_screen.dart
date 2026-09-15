import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:const Text("Регистрация"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Text(
            'Создать аккаунт',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: "Имя пользователя",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outlined),

            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),

            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: "Пароль",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.password_outlined),

            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: "Повторите пароль",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),

            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: (){}, child: const Text("Зарегестрироваться"))


        ],
      ),
    );
  }
}