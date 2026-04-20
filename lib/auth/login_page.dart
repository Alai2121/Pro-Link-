import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/fake_data.dart';
import '../models/admin.dart';
import '../admin/admin_dashboard.dart';
import '../models/mentor.dart';
import '../mentor/mentor_dashboard.dart';
import '../models/intern.dart';
import '../intern/intern_dashboard.dart';
import '../auth/register_page.dart';

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

    // ================= ADMIN =================
    try {
      Admin admin = FakeData.admin.firstWhere(
            (a) => a.name == name && a.password == password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminDashboard(admin: admin)),
      );
      return;
    } catch (_) {}

    // ================= MENTOR =================
    try {
      Mentor mentor = FakeData.mentors.firstWhere(
            (m) => m.name == name && m.password == password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MentorDashboard(mentor: mentor)),
      );
      return;
    } catch (_) {}

    // ================= INTERN =================
    try {
      Intern intern = FakeData.interns.firstWhere(
            (i) => i.name == name && i.password == password,
      );

      // ❌ NOT APPROVED
      if (intern.status.toLowerCase() != "approved") {
        setState(() {
          error = "⏳ You cannot login until approved by admin";
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InternDashboard(intern: intern),
        ),
      );
      return;
    } catch (_) {}

    setState(() => error = "Wrong username or password");
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

                Image.asset('assets/logo.png', width: 180),
                const SizedBox(height: 8),

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

                // USERNAME
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF2D3A8C)),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF2D3A8C)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
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
                  ),
                ),

                const SizedBox(height: 12),

                // ERROR MESSAGE
                if (error.isNotEmpty)
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 24),

                // LOGIN BUTTON
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
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= REGISTER LINK =================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF2D3A8C),
                      decoration: TextDecoration.underline,
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