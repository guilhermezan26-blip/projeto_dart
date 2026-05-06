import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class SactsApp extends StatelessWidget {
  const SactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SACTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}