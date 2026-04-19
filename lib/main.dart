import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'splash_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pro-Link Home"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Go to Admin Dashboard"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}