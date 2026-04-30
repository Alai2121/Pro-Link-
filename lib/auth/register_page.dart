import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/policy.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController  = TextEditingController();
  bool _isLoading       = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _agreedToPolicy  = false;
  List<Policy> _policies = [];

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    final data = await ApiService.getPolicies();
    setState(() => _policies = data);
  }

  Future<void> _showPolicies() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [

            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.policy_outlined, color: Color(0xFF2D3A8C)),
                  const SizedBox(width: 8),
                  Text("Company Policies",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF2D3A8C))),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _policies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _policies.length,
                itemBuilder: (context, index) {
                  final policy = _policies[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.policy_outlined,
                              color: Colors.indigo, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy.title,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                policy.description,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _agreedToPolicy = true);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3A8C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: Text("I Agree to the Policies",
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name     = nameController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text;
    final confirm  = confirmController.text;

    if (name.isEmpty || email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields (password 6+ chars)"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!email.endsWith('@prolink.dz')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email must be in format: name@prolink.dz"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"),
            backgroundColor: Colors.red),
      );
      return;
    }


    if (!_agreedToPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please read and agree to the company policies"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.register(name, email, password);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"]), backgroundColor: Colors.red),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text("Registration Submitted",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            "Your account is pending admin approval.\nYou'll be able to login once approved.",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3A8C)),
                child: Text("Go to Login",
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Icon(Icons.work_outline, size: 80, color: Color(0xFF2D3A8C)),
                  const SizedBox(height: 10),
                  Text("Create Account",
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3A8C))),
                  Text("Join Pro-Link Internship",
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: Column(
                      children: [


                        TextField(
                          controller: nameController,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Color(0xFF2D3A8C)),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FF),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),


                        TextField(
                          controller: emailController,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "yourname@prolink.dz",
                            hintStyle: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Color(0xFF2D3A8C)),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FF),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),


                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: "Password",
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
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: confirmController,
                          obscureText: _obscureConfirm,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Color(0xFF2D3A8C)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF4F6FF),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),


                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToPolicy,
                              activeColor: const Color(0xFF2D3A8C),
                              onChanged: (val) =>
                                  setState(() => _agreedToPolicy = val ?? false),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showPolicies,
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey.shade700),
                                    children: [
                                      const TextSpan(text: "I have read and agree to the "),
                                      TextSpan(
                                        text: "Company Policies",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF2D3A8C),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),


                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : register,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _agreedToPolicy
                                    ? const Color(0xFF2D3A8C)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text("Sign Up",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 16),


                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Already have an account? Login",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF2D3A8C),
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}