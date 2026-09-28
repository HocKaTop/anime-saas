import 'package:animesaas/models/catalog_model.dart';
import 'package:animesaas/repositories/mock_title_repository.dart';
import 'package:animesaas/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final repository = MockTitleRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockTitleRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => CatalogModel(repository)..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CreepyOleg',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC430C)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
