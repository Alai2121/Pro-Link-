import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intern.dart';
import '../../models/evaluation.dart';
import '../../data/fake_data.dart';

class MarksPage extends StatefulWidget {
  final Intern intern;

  const MarksPage({super.key, required this.intern});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  late List<Evaluation> myMarks;
  double average = 0;

  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();

    myMarks = FakeData.evaluations
        .where((e) => e.internId == widget.intern.id)
        .toList();

    if (myMarks.isNotEmpty) {
      int total = myMarks.fold(0, (sum, e) => sum + e.mark);
      average = total / myMarks.length;
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
          "Marks",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [


            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    average.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),


            Expanded(
              child: myMarks.isEmpty
                  ? Center(
                child: Text(
                  "No marks yet",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: myMarks.length,
                itemBuilder: (context, index) {
                  final mark = myMarks[index];

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
                          child: Icon(Icons.star, color: primary),
                        ),

                        const SizedBox(width: 12),


                        Expanded(
                          child: Text(
                            mark.skill,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),


                        Text(
                          mark.mark.toString(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
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