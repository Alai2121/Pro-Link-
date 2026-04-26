import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../../auth/login_page.dart';
import '../data/fake_data.dart';
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
  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final myInterns = FakeData.interns
        .where((i) => i.mentorId == widget.mentor.id)
        .toList();

    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayAttendances = FakeData.attendances
        .where((a) =>
    myInterns.any((i) => i.id == a.internId) && a.date == today)
        .toList();
    final presentToday = todayAttendances.where((a) => a.isPresent).length;
    final attendanceMarked = todayAttendances.isNotEmpty;

    final allEvals = FakeData.evaluations
        .where((e) => myInterns.any((i) => i.id == e.internId))
        .toList();
    final double globalAvg = allEvals.isEmpty
        ? 0
        : allEvals.map((e) => e.mark).reduce((a, b) => a + b) /
        allEvals.length;

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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage('assets/logoonly.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('Pro-Link',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child:
                    Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 13)),
                        Text(widget.mentor.name,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('${widget.mentor.department.name} Department',
                            style: GoogleFonts.poppins(
                                color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats row
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
                  value: allEvals.isEmpty
                      ? '—'
                      : globalAvg.toStringAsFixed(1),
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Today's attendance summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: attendanceMarked
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      attendanceMarked
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      color:
                      attendanceMarked ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Attendance",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(
                          attendanceMarked
                              ? '$presentToday / ${myInterns.length} present'
                              : 'Not marked yet',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: attendanceMarked
                                  ? Colors.green
                                  : Colors.orange),
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
                        )),
                    child: Text(
                      attendanceMarked ? 'View' : 'Mark',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF2D3A8C),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Quick Actions',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3A8C))),
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
                      )),
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
                      )),
                ),
                _MenuCard(
                  icon: Icons.star_outline,
                  label: 'Marks',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MentorMarks(mentor: widget.mentor),
                      )),
                ),
                _MenuCard(
                  icon: Icons.folder_outlined,
                  label: 'Training Files',
                  color: Colors.teal,
                  badge: '${FakeData.trainingFiles.where((f) => f.mentorId == widget.mentor.id).length}',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MentorTraining(mentor: widget.mentor),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
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
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
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
  const _MenuCard(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap,
        this.badge});

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
