import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/evaluation.dart';
import '../data/fake_data.dart';

class MentorMarks extends StatefulWidget {
  final Mentor mentor;
  const MentorMarks({super.key, required this.mentor});

  @override
  State<MentorMarks> createState() => _MentorMarksState();
}

class _MentorMarksState extends State<MentorMarks> {
  final List<String> skills = ['Communication', 'Technical', 'Teamwork', 'Punctuality', 'Initiative'];

  void _showMarkDialog(String internId, String internName) {
    String selectedSkill = skills[0];
    final markController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Mark for $internName', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSkill,
              decoration: InputDecoration(
                labelText: 'Skill',
                labelStyle: GoogleFonts.poppins(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: skills.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (val) => selectedSkill = val!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: markController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Mark (0-20)',
                labelStyle: GoogleFonts.poppins(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final mark = int.tryParse(markController.text);
              if (mark != null && mark >= 0 && mark <= 20) {
                setState(() {
                  FakeData.evaluations.add(Evaluation(
                    id: 'ev_${internId}_$selectedSkill',
                    internId: internId,
                    skill: selectedSkill,
                    mark: mark,
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A8C)),
            child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
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
        title: Text('Performance Marks', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myInterns.length,
        itemBuilder: (context, index) {
          final intern = myInterns[index];
          final internEvals = FakeData.evaluations.where((e) => e.internId == intern.id).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(intern.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF2D3A8C))),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF2D3A8C)),
                      onPressed: () => _showMarkDialog(intern.id, intern.name),
                    ),
                  ],
                ),
                if (internEvals.isEmpty)
                  Text('No marks yet', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
                else
                  ...internEvals.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.skill, style: GoogleFonts.poppins(fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: e.mark >= 10 ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: e.mark >= 10 ? Colors.green : Colors.red),
                          ),
                          child: Text(
                            '${e.mark}/20',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: e.mark >= 10 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}