import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ("Поиск"),
      ),
      body: const Center(
        child: Text("Поиск аниме"),
      ),
    );
  }
}