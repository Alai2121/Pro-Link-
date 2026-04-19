import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trainingFile.dart';
import '../data/fake_data.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late List<TrainingFile> documents;

  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();
    documents = FakeData.trainingFiles;
  }

  Future<void> downloadFile(String url) async {
    final uri = Uri.parse(url);

    // Open in browser → user downloads file
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw "Could not download file";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        title: Text(
          "Documents",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.insert_drive_file, color: primary),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap download",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => downloadFile(doc.fileUrl),
                  child: Icon(
                    Icons.download,
                    size: 22,
                    color: primary,
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