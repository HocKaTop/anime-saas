import 'package:flutter/material.dart';

class BrowseScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creepy Oleg"),
      ),
      body: const Center(
        child: Text("Главная"),
      ),
    );
  }
}