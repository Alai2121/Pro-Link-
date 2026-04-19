import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/fake_data.dart';
import '../models/admin.dart';
import '../admin/admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  String error = "";

  void login() {
    String name = nameController.text.trim();
    String password = passwordController.text.trim();

    try {
      Admin admin = FakeData.admin.firstWhere(
            (a) => a.name == name && a.password == password,
      );

      if (admin.role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboard(admin: admin),
          ),
        );
      } else {
        setState(() => error = "Access denied: Not an admin");
      }
    } catch (e) {
      setState(() => error = "Wrong username or password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Logo
                Image.asset('assets/logo.png', width: 180),
                const SizedBox(height: 8),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3A8C),
                  ),
                ),
                Text(
                  'Sign in to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 36),

                // Name field
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF2D3A8C)),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF2D3A8C), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF2D3A8C)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF2D3A8C), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Error message
                if (error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          error,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3A8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),


              ],
            ),
          ),
        ),
      ),
    );
  }
}