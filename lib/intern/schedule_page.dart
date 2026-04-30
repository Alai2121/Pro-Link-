import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intern.dart';
import '../../models/schedule.dart';
import '../../services/api_service.dart';

class SchedulePage extends StatefulWidget {
  final Intern intern;
  const SchedulePage({super.key, required this.intern});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Schedule> mySchedule = [];
  bool isLoading = true;
  final Color primary = const Color(0xFF2D3A8C);

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    setState(() => isLoading = true);
    final data = await ApiService.getSchedules(widget.intern.id);
    setState(() { mySchedule = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySchedule.isEmpty
          ? Center(child: Text("No schedule found",
          style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mySchedule.length,
        itemBuilder: (context, index) {
          final schedule = mySchedule[index];
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
                    Icon(Icons.schedule, color: primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(schedule.day,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: primary)),
                          Text(schedule.time,
                              style: GoogleFonts.poppins(
                                  color: Colors.grey)),
                          Text("Type: ${schedule.type}",
                              style: GoogleFonts.poppins(fontSize: 12)),
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
                      child: Text(schedule.internName,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}