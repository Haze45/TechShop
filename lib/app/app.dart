import 'package:flutter/material.dart';

class TechShopApp extends StatelessWidget {
  const TechShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Welcome to TechShop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
