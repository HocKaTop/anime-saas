import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPassowrdController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPassowrdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Регистрационные данные коректны")),
      );
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
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Имя пользователя",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Введите Имя пользователя";
                }
                if (value.length < 3) {
                  return "Имя пользователя должно быть больше 3 символов";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
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
                if (value.length < 6) {
                  return "Длина пароля минимум 6 символов";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPassowrdController,
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
              onPressed: _submit,
              child: const Text("Зарегестрироваться"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Уже есть аккаунт? Войти"),
            ),
          ],
        ),
      ),
    );
  }
}
