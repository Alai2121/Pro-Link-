import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/intern.dart';
import '../models/trainingFile.dart';
import '../services/api_service.dart';

class DocumentsPage extends StatefulWidget {
  final Intern intern;
  const DocumentsPage({super.key, required this.intern});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<TrainingFile> _files = [];
  bool _isLoading = true;
  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final files    = await ApiService.getMyTrainingFiles(widget.intern.mentorId);
    final policies = await ApiService.getPolicies();
    setState(() { _files = files; _isLoading = false; });
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file')),
      );
    }
  }

  Widget _fileCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.open_in_new, color: color, size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_files.isEmpty )
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No documents yet',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_files.isNotEmpty) ...[
                    Text("Training Files",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: primary)),
                    const SizedBox(height: 10),
                    ..._files.map((file) => GestureDetector(
                      onTap: () => _openFile(file.fileUrl),
                      child: _fileCard(
                        title: file.title,
                        subtitle: file.fileUrl,
                        icon: Icons.insert_drive_file_outlined,
                        color: Colors.teal,
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}