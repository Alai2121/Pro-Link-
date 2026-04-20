import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intern.dart';
import '../../models/schedule.dart';
import '../../data/fake_data.dart';

class SchedulePage extends StatefulWidget {
  final Intern intern;

  const SchedulePage({super.key, required this.intern});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late List<Schedule> mySchedule;

  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();

    mySchedule = FakeData.schedules
        .where((s) => s.internId == widget.intern.id)
        .toList();
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
          "Schedule",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: mySchedule.isEmpty
          ? Center(
        child: Text(
          "No schedule yet",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mySchedule.length,
        itemBuilder: (context, index) {
          final schedule = mySchedule[index];

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
                  child: Icon(Icons.schedule, color: primary),
                ),

                const SizedBox(width: 12),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        schedule.day,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        schedule.time,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Type: ${schedule.type}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),


                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.internName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                    ),
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