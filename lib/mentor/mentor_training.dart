import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/trainingFile.dart';
import '../services/api_service.dart';

class MentorTraining extends StatefulWidget {
  final Mentor mentor;
  const MentorTraining({super.key, required this.mentor});

  @override
  State<MentorTraining> createState() => _MentorTrainingState();
}

class _MentorTrainingState extends State<MentorTraining> {
  final titleController = TextEditingController();
  final urlController   = TextEditingController();
  List<TrainingFile> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getTrainingFiles(widget.mentor.id);
    setState(() { _files = data; _isLoading = false; });
  }

  void _addFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Training File',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
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
            onPressed: () async {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final id = await ApiService.addTrainingFile(
                  widget.mentor.id,
                  titleController.text,
                  urlController.text,
                );
                if (id != null) {
                  titleController.clear();
                  urlController.clear();
                  Navigator.pop(context);
                  _load(); // refresh from DB
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A8C)),
            child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(TrainingFile file) async {
    await ApiService.deleteTrainingFile(file.id);
    _load(); // refresh from DB
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('Training Files',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        backgroundColor: const Color(0xFF2D3A8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No training files yet', style: GoogleFonts.poppins(color: Colors.grey)),
            Text('Tap + to add one',
                style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined,
                      color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.title,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(file.fileUrl,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteFile(file),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}