import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/attendance.dart';
import '../data/fake_data.dart';

class MentorAttendance extends StatefulWidget {
  final Mentor mentor;
  const MentorAttendance({super.key, required this.mentor});

  @override
  State<MentorAttendance> createState() => _MentorAttendanceState();
}

class _MentorAttendanceState extends State<MentorAttendance> {
  final Map<String, bool> _attendance = {};
  final String today = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    final myInterns = FakeData.interns.where((i) => i.mentorId == widget.mentor.id);
    for (var intern in myInterns) {
      _attendance[intern.id] = false;
    }
  }

  void saveAttendance() {
    _attendance.forEach((internId, isPresent) {
      FakeData.attendances.add(Attendance(
        id: 'att_${internId}_$today',
        internId: internId,
        date: today,
        isPresent: isPresent,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance saved for $today', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF2D3A8C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myInterns = FakeData.interns
        .where((i) => i.mentorId == widget.mentor.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('Attendance', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Date header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3A8C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Date: $today',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: myInterns.length,
              itemBuilder: (context, index) {
                final intern = myInterns[index];
                final isPresent = _attendance[intern.id] ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2D3A8C).withOpacity(0.1),
                        child: Text(
                          intern.name[0].toUpperCase(),
                          style: GoogleFonts.poppins(color: const Color(0xFF2D3A8C), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(intern.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      Switch(
                        value: isPresent,
                        activeColor: const Color(0xFF2D3A8C),
                        onChanged: (val) => setState(() => _attendance[intern.id] = val),
                      ),
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isPresent ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3A8C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save Attendance', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}