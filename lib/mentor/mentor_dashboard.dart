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

// ─── Shared avatar state ──────────────────────────────────────────────────────
class _AvatarState {
  File? localFile;
  String? networkUrl;
  bool uploading = false;

  _AvatarState({this.localFile, this.networkUrl});
}

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

  // Single source of truth for avatar — drives both the dashboard card
  // and the profile sheet simultaneously via ValueNotifier.
  late final ValueNotifier<_AvatarState> _avatarNotifier;

  @override
  void initState() {
    super.initState();
    _avatarNotifier = ValueNotifier(
      _AvatarState(networkUrl: _normalizeImageUrl(widget.mentor.image)),
    );
    internsFuture = ApiService.getMyInterns(widget.mentor.id);
    attendanceFuture = ApiService.getAttendance(widget.mentor.id);
    marksFuture = ApiService.getMarks(widget.mentor.id);
  }

  @override
  void dispose() {
    _avatarNotifier.dispose();
    super.dispose();
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

  // ─── Pick & upload ─────────────────────────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourcePickerSheet(),
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

    // Immediately show local preview + spinner — notifies every ValueListenableBuilder
    _avatarNotifier.value = _AvatarState(
      localFile: file,
      networkUrl: _avatarNotifier.value.networkUrl,
    )..uploading = true;

    final newUrl = await ApiService.updateMentorProfileImage(
      widget.mentor.id,
      file.path,
    );

    if (!mounted) return;

    if (newUrl != null && newUrl.isNotEmpty) {
      _avatarNotifier.value = _AvatarState(
        networkUrl: _normalizeImageUrl(newUrl),
      );
    } else {
      // Revert to whatever was showing before on failure
      _avatarNotifier.value = _AvatarState(
        networkUrl: _avatarNotifier.value.networkUrl,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newUrl != null ? 'Profile photo updated!' : 'Upload failed. Try again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: newUrl != null ? const Color(0xFF2D3A8C) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Profile sheet ─────────────────────────────────────────────────────────
  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        mentor: widget.mentor,
        avatarNotifier: _avatarNotifier,
        onPickAndUpload: _pickAndUpload,
        onLogout: () {
          Navigator.pop(context);
          _logout();
        },
      ),
    );
  }

  // ─── Avatar widget (reads from notifier) ───────────────────────────────────
  Widget _buildAvatar({required double radius}) {
    return ValueListenableBuilder<_AvatarState>(
      valueListenable: _avatarNotifier,
      builder: (_, state, __) {
        return _AvatarWidget(
          state: state,
          radius: radius,
          fallbackName: widget.mentor.name,
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
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
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
              child:
              Text("Error loading data", style: GoogleFonts.poppins()),
            );
          }

          final List<Intern> myInterns = snapshot.data![0];
          final List<Attendance> attendances = snapshot.data![1];
          final List<Evaluation> evals = snapshot.data![2];

          final today = DateTime.now().toIso8601String().split('T')[0];
          final todayAttendances =
          attendances.where((a) => a.date == today).toList();
          final presentToday =
              todayAttendances.where((a) => a.isPresent).length;
          final attendanceMarked = todayAttendances.isNotEmpty;

          final double globalAvg = evals.isEmpty
              ? 0
              : evals.map((e) => e.mark).reduce((a, b) => a + b) /
              evals.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome card ──────────────────────────────────────────
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
                        // Avatar updates instantly because it reads the notifier
                        _buildAvatar(radius: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13),
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
                                    color: Colors.white60, fontSize: 12),
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

                // ── Stat cards ────────────────────────────────────────────
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
                      value:
                      '${myInterns.where((i) => i.status == "Approved").length}',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.star_rounded,
                      label: 'Avg Mark',
                      value: evals.isEmpty
                          ? '—'
                          : globalAvg.toStringAsFixed(1),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Attendance banner ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        attendanceMarked
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        color:
                        attendanceMarked ? Colors.green : Colors.orange,
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
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            Text(
                              attendanceMarked
                                  ? '$presentToday / ${myInterns.length} present'
                                  : 'Not marked yet',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: attendanceMarked
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MentorAttendance(mentor: widget.mentor),
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

                // ── Quick actions ─────────────────────────────────────────
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
                          builder: (_) =>
                              MentorInterns(mentor: widget.mentor),
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
                          builder: (_) =>
                              MentorAttendance(mentor: widget.mentor),
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
                          builder: (_) =>
                              MentorTraining(mentor: widget.mentor),
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
}

// ─── Pure avatar widget — no setState, just reads _AvatarState ────────────────
class _AvatarWidget extends StatelessWidget {
  final _AvatarState state;
  final double radius;
  final String fallbackName;

  const _AvatarWidget({
    required this.state,
    required this.radius,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (state.localFile != null) {
      imageProvider = FileImage(state.localFile!);
    } else if (state.networkUrl != null && state.networkUrl!.isNotEmpty) {
      imageProvider = state.networkUrl!.startsWith('assets/')
          ? AssetImage(state.networkUrl!) as ImageProvider
          : NetworkImage(state.networkUrl!);
    }

    final avatar = imageProvider != null
        ? CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      backgroundColor: Colors.white24,
      onBackgroundImageError: (_, __) {},
    )
        : CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      child: Text(
        fallbackName[0].toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );

    if (!state.uploading) return avatar;

    // Overlay a spinner while uploading
    return Stack(
      alignment: Alignment.center,
      children: [
        avatar,
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: radius * 0.07,
          ),
        ),
      ],
    );
  }
}

// ─── Source picker sheet (stateless) ─────────────────────────────────────────
class _SourcePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3A8C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF2D3A8C)),
            ),
            title: Text('Choose from Gallery',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF6C63FF)),
            ),
            title: Text('Take a Photo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Profile sheet (reads notifier directly — no StatefulBuilder needed) ──────
class _ProfileSheet extends StatelessWidget {
  final Mentor mentor;
  final ValueNotifier<_AvatarState> avatarNotifier;
  final VoidCallback onPickAndUpload;
  final VoidCallback onLogout;

  const _ProfileSheet({
    required this.mentor,
    required this.avatarNotifier,
    required this.onPickAndUpload,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      // Never taller than 90 % of the screen so it can't overflow
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle (fixed, not scrollable) ──────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 24,
                  bottom: bottomInset + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Avatar + camera button — rebuilds on every notifier change
                    ValueListenableBuilder<_AvatarState>(
                      valueListenable: avatarNotifier,
                      builder: (_, state, __) {
                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _AvatarWidget(
                                  state: state,
                                  radius: 48,
                                  fallbackName: mentor.name,
                                ),
                                GestureDetector(
                                  onTap: state.uploading ? null : onPickAndUpload,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: state.uploading
                                          ? Colors.grey
                                          : const Color(0xFF2D3A8C),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Icon(
                                      state.uploading
                                          ? Icons.hourglass_top
                                          : Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (state.uploading) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Uploading…',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      mentor.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: const Color(0xFF2D3A8C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mentor.email,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3)),
                      ),
                      child: Text(
                        mentor.department.name,
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
                        value: mentor.id),
                    const Divider(height: 1),
                    _ProfileInfoRow(
                        icon: Icons.apartment_outlined,
                        label: 'Department',
                        value: mentor.department.name),
                    const Divider(height: 1),
                    _ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: mentor.email),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: onLogout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon:
                        const Icon(Icons.logout, color: Colors.red, size: 18),
                        label: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting widgets (unchanged) ──────────────────────────────────────────
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileInfoRow(
      {required this.icon, required this.label, required this.value});

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
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade500)),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3A8C))),
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

  const _StatCard(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

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
                color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center),
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
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
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
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3A8C))),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge == '!'
                        ? Colors.orange
                        : const Color(0xFF2D3A8C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}