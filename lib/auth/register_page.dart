import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart'; // Import your API service

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields (password 6+ chars)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call your real API
    final result = await ApiService.register(name, email, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered! Waiting for approval"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to login
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
              children: [
                const Icon(Icons.work_outline, size: 80, color: Color(0xFF2D3A8C)),
                const SizedBox(height: 10),
                Text("Create Account", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A8C))),
                Text("Join Pro-Link Internship", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))]),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(labelText: "Full Name", prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2D3A8C)), filled: true, fillColor: const Color(0xFFF4F6FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2D3A8C)), filled: true, fillColor: const Color(0xFFF4F6FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2D3A8C)), filled: true, fillColor: const Color(0xFFF4F6FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : register,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A8C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text("Sign Up", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Already have an account? Login", style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2D3A8C), decoration: TextDecoration.underline)),
                      ),
                    ],
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