import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/intern.dart';
import '../data/fake_data.dart';

class MentorInterns extends StatelessWidget {
  final Mentor mentor;
  const MentorInterns({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final myInterns = FakeData.interns
        .where((i) => i.mentorId == mentor.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('My Interns', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: myInterns.isEmpty
          ? Center(child: Text('No interns assigned yet', style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myInterns.length,
        itemBuilder: (context, index) {
          final intern = myInterns[index];
          return _InternCard(intern: intern);
        },
      ),
    );
  }
}

class _InternCard extends StatelessWidget {
  final Intern intern;
  const _InternCard({required this.intern});

  @override
  Widget build(BuildContext context) {
    final isApproved = intern.status == "Approved";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2D3A8C).withOpacity(0.1),
            child: Text(
              intern.name[0].toUpperCase(),
              style: GoogleFonts.poppins(color: const Color(0xFF2D3A8C), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intern.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(intern.email, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text(intern.department.name, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isApproved ? Colors.green : Colors.orange),
            ),
            child: Text(
              intern.status,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isApproved ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}