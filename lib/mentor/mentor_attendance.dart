import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/intern.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class MentorAttendance extends StatefulWidget {
  final Mentor mentor;
  const MentorAttendance({super.key, required this.mentor});

  @override
  State<MentorAttendance> createState() => _MentorAttendanceState();
}

class _MentorAttendanceState extends State<MentorAttendance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> _attendance = {};
  final String today = DateTime.now().toIso8601String().split('T')[0];

  List<Intern> _interns = [];
  List<Attendance> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final interns  = await ApiService.getMyInterns(widget.mentor.id);
    final history  = await ApiService.getAttendance(widget.mentor.id);

    final Map<String, bool> map = {};
    for (final intern in interns) {
      final existing = history.where((a) => a.internId == intern.id && a.date == today);
      map[intern.id] = existing.isNotEmpty ? existing.first.isPresent : false;
    }

    setState(() {
      _interns    = interns;
      _history    = history;
      _attendance = map as Map<String, bool>;
      _isLoading  = false;
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveAttendance() async {
    for (final entry in _attendance.entries) {
      await ApiService.saveAttendance(entry.key, today, entry.value);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Attendance saved for $today', style: GoogleFonts.poppins()),
      backgroundColor: const Color(0xFF2D3A8C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    _load(); // refresh history tab
  }

  @override
  Widget build(BuildContext context) {
    final presentToday = _attendance.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('Attendance',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Today'), Tab(text: 'History')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _TodayTab(
            myInterns: _interns,
            attendance: _attendance,
            today: today,
            presentCount: presentToday,
            onChanged: (id, val) => setState(() => _attendance[id] = val),
            onSave: _saveAttendance,
          ),
          _HistoryTab(myInterns: _interns, history: _history),
        ],
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  final List<Intern> myInterns;
  final Map<String, bool> attendance;
  final String today;
  final int presentCount;
  final void Function(String, bool) onChanged;
  final VoidCallback onSave;

  const _TodayTab({
    required this.myInterns, required this.attendance, required this.today,
    required this.presentCount, required this.onChanged, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2D3A8C), Color(0xFF6C63FF)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(today,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
              Text('$presentCount / ${myInterns.length} present',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: myInterns.length,
            itemBuilder: (context, index) {
              final intern = myInterns[index];
              final isPresent = attendance[intern.id] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isPresent ? Colors.green.withOpacity(0.3) : Colors.transparent),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isPresent
                          ? Colors.green.withOpacity(0.12)
                          : const Color(0xFF2D3A8C).withOpacity(0.1),
                      child: Text(intern.name[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                              color: isPresent ? Colors.green.shade700 : const Color(0xFF2D3A8C),
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(intern.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14))),
                    Text(isPresent ? 'Present' : 'Absent',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isPresent ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Switch(
                        value: isPresent,
                        activeColor: Colors.green,
                        onChanged: (val) => onChanged(intern.id, val)),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3A8C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: Text('Save Attendance',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<Intern> myInterns;
  final List<Attendance> history;
  const _HistoryTab({required this.myInterns, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No history yet', style: GoogleFonts.poppins(color: Colors.grey)),
        ]),
      );
    }

    final Map<String, List<Attendance>> byDate = {};
    for (final a in history) {
      byDate.putIfAbsent(a.date, () => []).add(a);
    }
    final sortedDates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, i) {
        final date    = sortedDates[i];
        final records = byDate[date]!;
        final presentCount = records.where((r) => r.isPresent).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF2D3A8C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today, color: Color(0xFF2D3A8C), size: 18),
            ),
            title: Text(date,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('$presentCount / ${records.length} present',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: presentCount == records.length ? Colors.green : Colors.orange)),
            children: records.map((r) {
              final internList = myInterns.where((i) => i.id == r.internId);
              if (internList.isEmpty) return const SizedBox.shrink();
              final intern = internList.first;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: r.isPresent
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  child: Icon(r.isPresent ? Icons.check : Icons.close,
                      size: 16, color: r.isPresent ? Colors.green : Colors.red),
                ),
                title: Text(intern.name, style: GoogleFonts.poppins(fontSize: 13)),
                trailing: Text(r.isPresent ? 'Present' : 'Absent',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: r.isPresent ? Colors.green : Colors.red)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}