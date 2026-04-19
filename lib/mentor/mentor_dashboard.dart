import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../data/fake_data.dart';
import 'mentor_interns.dart';
import 'mentor_attendance.dart';
import 'mentor_marks.dart';
import 'mentor_training.dart';

class MentorDashboard extends StatelessWidget {
  final Mentor mentor;
  const MentorDashboard({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final myInterns = FakeData.interns
        .where((i) => i.mentorId == mentor.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
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
            onPressed: () => Navigator.pop(context),
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
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        mentor.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${mentor.department.name} Department',
                        style: GoogleFonts.poppins(
                            color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                  value: '${myInterns.where((i) => i.status == "Approved").length}',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.pending,
                  label: 'Pending',
                  value: '${myInterns.where((i) => i.status == "Pending").length}',
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3A8C),
              ),
            ),
            const SizedBox(height: 14),

            // Menu grid
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MentorInterns(mentor: mentor),
                  )),
                ),
                _MenuCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Attendance',
                  color: const Color(0xFF6C63FF),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MentorAttendance(mentor: mentor),
                  )),
                ),
                _MenuCard(
                  icon: Icons.star_outline,
                  label: 'Marks',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MentorMarks(mentor: mentor),
                  )),
                ),
                _MenuCard(
                  icon: Icons.folder_outlined,
                  label: 'Training Files',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MentorTraining(mentor: mentor),
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
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
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
  const _MenuCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
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
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D3A8C))),
          ],
        ),
      ),
    );
  }
}