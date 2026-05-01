import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../models/mentor.dart';
import '../models/intern.dart';
import '../models/attendance.dart';
import '../models/evaluation.dart';
import '../../auth/login_page.dart';
import 'mentor_interns.dart';
import 'mentor_attendance.dart';
import 'mentor_marks.dart';
import 'mentor_training.dart';

class MentorDashboard extends StatefulWidget {
  final Mentor mentor;
  const MentorDashboard({super.key, required this.mentor});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  late Future<List<Intern>> internsFuture;
  late Future<List<Attendance>> attendanceFuture;
  late Future<List<Evaluation>> marksFuture;

  String? _networkImageUrl;
  File? _localImageFile;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _networkImageUrl = _normalizeImageUrl(widget.mentor.image);
    internsFuture = ApiService.getMyInterns(widget.mentor.id);
    attendanceFuture = ApiService.getAttendance(widget.mentor.id);
    marksFuture = ApiService.getMarks(widget.mentor.id);
  }

  String? _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    if (url.startsWith('assets/')) return url;
    return '${ApiService.baseUrl}/$url';
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _pickAndUpload() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Change Profile Photo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3A8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF2D3A8C),
                ),
              ),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF6C63FF),
                ),
              ),
              title: Text(
                'Take a Photo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      _localImageFile = file;
      _uploadingImage = true;
    });

    final newUrl = await ApiService.updateMentorProfileImage(
      widget.mentor.id,
      file.path,
    );

    if (!mounted) return;

    setState(() {
      _uploadingImage = false;
      if (newUrl != null && newUrl.isNotEmpty) {
        _networkImageUrl = _normalizeImageUrl(newUrl);
        _localImageFile = null;
      } else {
        _localImageFile = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newUrl != null ? 'Profile photo updated!' : 'Upload failed. Try again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: newUrl != null ? const Color(0xFF2D3A8C) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _uploadingImage
                      ? SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildAvatar(radius: 48),
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  )
                      : _buildAvatar(radius: 48),
                  GestureDetector(
                    onTap: () async {
                      await _pickAndUpload();
                      setSheetState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3A8C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (_uploadingImage)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Uploading…',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                widget.mentor.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color(0xFF2D3A8C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.mentor.email,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.mentor.department.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _ProfileInfoRow(
                icon: Icons.badge_outlined,
                label: 'Mentor ID',
                value: widget.mentor.id,
              ),
              const Divider(height: 1),
              _ProfileInfoRow(
                icon: Icons.apartment_outlined,
                label: 'Department',
                value: widget.mentor.department.name,
              ),
              const Divider(height: 1),
              _ProfileInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: widget.mentor.email,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _logout();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/logoonly.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Text(
              'Pro-Link',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([internsFuture, attendanceFuture, marksFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text("Error loading data", style: GoogleFonts.poppins()),
            );
          }

          final List<Intern> myInterns = snapshot.data![0];
          final List<Attendance> attendances = snapshot.data![1];
          final List<Evaluation> evals = snapshot.data![2];

          final today = DateTime.now().toIso8601String().split('T')[0];
          final todayAttendances = attendances.where((a) => a.date == today).toList();
          final presentToday = todayAttendances.where((a) => a.isPresent).length;
          final attendanceMarked = todayAttendances.isNotEmpty;

          final double globalAvg = evals.isEmpty
              ? 0
              : evals.map((e) => e.mark).reduce((a, b) => a + b) / evals.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showProfileSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D3A8C), Color(0xFF6C63FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildAvatar(radius: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                widget.mentor.name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.mentor.department.name} Department',
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined,
                            color: Colors.white38, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.group,
                      label: 'My Interns',
                      value: '${myInterns.length}',
                      color: const Color(0xFF2D3A8C),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Approved',
                      value: '${myInterns.where((i) => i.status == "Approved").length}',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.star_rounded,
                      label: 'Avg Mark',
                      value: evals.isEmpty ? '—' : globalAvg.toStringAsFixed(1),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        attendanceMarked
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        color: attendanceMarked ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Attendance",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              attendanceMarked
                                  ? '$presentToday / ${myInterns.length} present'
                                  : 'Not marked yet',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: attendanceMarked ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MentorAttendance(mentor: widget.mentor),
                          ),
                        ),
                        child: Text(
                          attendanceMarked ? 'View' : 'Mark',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2D3A8C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3A8C),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _MenuCard(
                      icon: Icons.group_outlined,
                      label: 'My Interns',
                      color: const Color(0xFF2D3A8C),
                      badge: '${myInterns.length}',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MentorInterns(mentor: widget.mentor),
                        ),
                      ),
                    ),
                    _MenuCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Attendance',
                      color: const Color(0xFF6C63FF),
                      badge: attendanceMarked ? null : '!',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MentorAttendance(mentor: widget.mentor),
                        ),
                      ),
                    ),
                    _MenuCard(
                      icon: Icons.star_outline,
                      label: 'Marks',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MentorMarks(mentor: widget.mentor),
                        ),
                      ),
                    ),
                    _MenuCard(
                      icon: Icons.folder_outlined,
                      label: 'Training Files',
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MentorTraining(mentor: widget.mentor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar({required double radius}) {
    ImageProvider? imageProvider;

    if (_localImageFile != null) {
      imageProvider = FileImage(_localImageFile!);
    } else if (_networkImageUrl != null && _networkImageUrl!.isNotEmpty) {
      if (_networkImageUrl!.startsWith('assets/')) {
        imageProvider = AssetImage(_networkImageUrl!);
      } else {
        imageProvider = NetworkImage(_networkImageUrl!);
      }
    }

    if (imageProvider != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: Colors.white24,
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      child: Text(
        widget.mentor.name[0].toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3A8C).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2D3A8C), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3A8C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3A8C),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge == '!' ? Colors.orange : const Color(0xFF2D3A8C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}