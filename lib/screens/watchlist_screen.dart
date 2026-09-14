import 'package:flutter/material.dart';

class WatchllistScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Мой список"),
      ),
      body: const Center(
        child: Text("Сохраненные аниме"),
      )
    );
  }
}