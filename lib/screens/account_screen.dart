import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
      ),
      body: const Center(
        child: const Text ("Аккаунт пользователя"),
      ),
    );
  }
}