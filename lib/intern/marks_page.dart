import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intern.dart';
import '../../models/evaluation.dart';
import '../../services/api_service.dart';

class MarksPage extends StatefulWidget {
  final Intern intern;
  const MarksPage({super.key, required this.intern});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  List<Evaluation> myMarks = [];
  double average = 0;
  bool isLoading = true;
  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();
    loadMarks();
  }

  Future<void> loadMarks() async {
    setState(() => isLoading = true);
    final data = await ApiService.getMyMarks(widget.intern.id);
    if (data.isNotEmpty) {
      int total = data.fold(0, (sum, e) => sum + e.mark);
      average = total / data.length;
    }
    setState(() { myMarks = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: MediaQuery.of(context).orientation == Orientation.portrait
                        ? 20
                        : 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Average Score",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait
                              ? 13
                              : 11,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        average.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait
                              ? 28
                              : 22,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: myMarks.isEmpty
                  ? Center(child: Text("No marks yet",
                  style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                itemCount: myMarks.length,
                itemBuilder: (context, index) {
                  final mark = myMarks[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
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
                              child: Icon(Icons.star, color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(mark.skill,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text(mark.mark.toString(),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}