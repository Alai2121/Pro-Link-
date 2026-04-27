import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/intern.dart';
import '../models/evaluation.dart';
import '../services/api_service.dart';

class MentorMarks extends StatefulWidget {
  final Mentor mentor;
  const MentorMarks({super.key, required this.mentor});

  @override
  State<MentorMarks> createState() => _MentorMarksState();
}

class _MentorMarksState extends State<MentorMarks> {
  List<Intern> _interns = [];
  List<Evaluation> _evals = [];
  bool _isLoading = true;

  final List<String> skills = [
    'Communication', 'Technical', 'Teamwork', 'Punctuality', 'Initiative',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final interns = await ApiService.getMyInterns(widget.mentor.id);
    final evals   = await ApiService.getMarks(widget.mentor.id);
    setState(() { _interns = interns; _evals = evals; _isLoading = false; });
  }

  Color _markColor(int mark) {
    if (mark >= 16) return Colors.green.shade700;
    if (mark >= 10) return Colors.orange;
    return Colors.red;
  }

  String _markLabel(double avg) {
    if (avg >= 16) return 'Excellent';
    if (avg >= 14) return 'Good';
    if (avg >= 10) return 'Average';
    return 'Needs Work';
  }

  void _showMarkDialog(String internId, String internName) {
    String selectedSkill = skills[0];
    final markController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Mark — $internName',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSkill,
                decoration: InputDecoration(
                  labelText: 'Skill',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF2D3A8C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: skills
                    .map((s) => DropdownMenuItem(
                    value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedSkill = val!),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: markController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mark (0 – 20)',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.grade_outlined, color: Color(0xFF2D3A8C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final mark = int.tryParse(markController.text);
                if (mark != null && mark >= 0 && mark <= 20) {
                  await ApiService.saveMark(internId, selectedSkill, mark);
                  Navigator.pop(context);
                  _load(); // refresh from DB
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3A8C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 16),
              label: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
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
        title: Text('Performance Marks',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interns.isEmpty
          ? Center(child: Text('No interns assigned', style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _interns.length,
        itemBuilder: (context, index) {
          final intern = _interns[index];
          final evals = _evals.where((e) => e.internId == intern.id).toList();
          final double avg = evals.isEmpty
              ? 0
              : evals.map((e) => e.mark).reduce((a, b) => a + b) / evals.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3A8C).withOpacity(0.04),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2D3A8C).withOpacity(0.12),
                        child: Text(intern.name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF2D3A8C),
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(intern.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: const Color(0xFF2D3A8C))),
                            if (evals.isNotEmpty)
                              Text(
                                'Avg: ${avg.toStringAsFixed(1)}/20 · ${_markLabel(avg)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: _markColor(avg.round())),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D3A8C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                        onPressed: () => _showMarkDialog(intern.id, intern.name),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: evals.isEmpty
                      ? Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text('No marks yet — tap + to add',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                      : Column(
                    children: evals.map((e) {
                      final color = _markColor(e.mark);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.skill,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${e.mark}/20',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: e.mark / 20,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}