import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/trainingFile.dart';
import '../data/fake_data.dart';

class MentorTraining extends StatefulWidget {
  final Mentor mentor;
  const MentorTraining({super.key, required this.mentor});

  @override
  State<MentorTraining> createState() => _MentorTrainingState();
}

class _MentorTrainingState extends State<MentorTraining> {
  final titleController = TextEditingController();
  final urlController = TextEditingController();

  void _addFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Training File', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'File Title',
                labelStyle: GoogleFonts.poppins(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'File URL or Path',
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
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                setState(() {
                  FakeData.trainingFiles.add(TrainingFile(
                    id: 'tf_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    fileUrl: urlController.text,
                    mentorId: widget.mentor.id,
                  ));
                });
                titleController.clear();
                urlController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A8C)),
            child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myFiles = FakeData.trainingFiles
        .where((f) => f.mentorId == widget.mentor.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('Training Files', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        backgroundColor: const Color(0xFF2D3A8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: myFiles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No training files yet', style: GoogleFonts.poppins(color: Colors.grey)),
            Text('Tap + to add one', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myFiles.length,
        itemBuilder: (context, index) {
          final file = myFiles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(file.fileUrl, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => FakeData.trainingFiles.remove(file)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}