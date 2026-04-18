import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/admin.dart';
import '../admin/admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String error = "";

  void login() {
    String name = nameController.text.trim();
    String password = passwordController.text.trim();

    try {
      // 🔥 البحث داخل قائمة admins
      Admin admin = FakeData.admin.firstWhere(
            (a) => a.name == name && a.password == password,
      );

      // 🔥 التحقق من role (مهم للتوسعة لاحقاً)
      if (admin.role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboard(admin: admin),
          ),
        );
      } else {
        setState(() {
          error = "Access denied: Not an admin";
        });
      }
    } catch (e) {
      setState(() {
        error = "Wrong username or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                if (error.isNotEmpty)
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}