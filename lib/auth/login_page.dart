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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String error = "";

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      error = '';
    });

    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 300));

    final name = nameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }

    // Admin
    try {
      Admin admin = FakeData.admin.firstWhere(
            (a) => a.name == name && a.password == password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => AdminDashboard(admin: admin)));
      return;
    } catch (_) {}

    // Mentor
    try {
      Mentor mentor = FakeData.mentors.firstWhere(
            (m) => m.name == name && m.password == password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => MentorDashboard(mentor: mentor)));
      return;
    } catch (_) {}

    // Intern
    try {
      Intern intern = FakeData.interns.firstWhere(
            (i) => i.name == name && i.password == password,
      );
      if (intern.status.toLowerCase() != "approved") {
        setState(() {
          error = "⏳ Your account is pending admin approval";
          _isLoading = false;
        });
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => InternDashboard(intern: intern)));
      return;
    } catch (_) {}

    setState(() {
      error = "Incorrect username or password";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset('assets/logo.png', width: 160),
                    const SizedBox(height: 6),

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

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          Text('Username',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3A8C))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            style: GoogleFonts.poppins(fontSize: 14),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey.shade400),
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

                          const SizedBox(height: 18),

                          // Password
                          Text('Password',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3A8C))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(fontSize: 14),
                            onSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Color(0xFF2D3A8C)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF4F6FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          // Error
                          if (error.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade400, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(error,
                                        style: GoogleFonts.poppins(
                                            color: Colors.red.shade600,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D3A8C),
                                disabledBackgroundColor:
                                const Color(0xFF2D3A8C).withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text('Sign In',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage())),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade600),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Register',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2D3A8C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
