import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';
import '../models/intern.dart';
import '../models/evaluation.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class MentorInterns extends StatefulWidget {
  final Mentor mentor;
  const MentorInterns({super.key, required this.mentor});

  @override
  State<MentorInterns> createState() => _MentorInternsState();
}

class _MentorInternsState extends State<MentorInterns> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Intern> _interns = [];
  List<Evaluation> _evals = [];
  List<Attendance> _attendances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final interns     = await ApiService.getMyInterns(widget.mentor.id);
    final evals       = await ApiService.getMarks(widget.mentor.id);
    final attendances = await ApiService.getAttendance(widget.mentor.id);
    setState(() {
      _interns     = interns;
      _evals       = evals;
      _attendances = attendances;
      _isLoading   = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showInternDetails(Intern intern) {
    final evals       = _evals.where((e) => e.internId == intern.id).toList();
    final attendances = _attendances.where((a) => a.internId == intern.id).toList();
    final presentCount = attendances.where((a) => a.isPresent).length;
    final double avgMark = evals.isEmpty
        ? 0
        : evals.map((e) => e.mark).reduce((a, b) => a + b) / evals.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2D3A8C).withOpacity(0.12),
                  child: Text(intern.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3A8C))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(intern.name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
                      Text(intern.email,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      Text(intern.department.name,
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF))),
                    ],
                  ),
                ),
                _StatusBadge(status: intern.status),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _DetailStat(
                  label: 'Avg Mark',
                  value: avgMark == 0 ? '—' : '${avgMark.toStringAsFixed(1)}/20',
                  icon: Icons.star_rounded, color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _DetailStat(
                  label: 'Present',
                  value: '$presentCount/${attendances.length}',
                  icon: Icons.calendar_today_rounded, color: const Color(0xFF2D3A8C),
                ),
                const SizedBox(width: 12),
                _DetailStat(
                  label: 'Skills',
                  value: '${evals.length}',
                  icon: Icons.emoji_events_rounded, color: Colors.teal,
                ),
              ],
            ),
            if (evals.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Performance',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14,
                      color: const Color(0xFF2D3A8C))),
              const SizedBox(height: 10),
              ...evals.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 90,
                        child: Text(e.skill, style: GoogleFonts.poppins(fontSize: 12))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: e.mark / 20, minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            e.mark >= 14 ? Colors.green : e.mark >= 10 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.mark}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _interns
        : _interns.where((i) =>
    i.name.toLowerCase().contains(_query.toLowerCase()) ||
        i.email.toLowerCase().contains(_query.toLowerCase()) ||
        i.department.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        title: Text('My Interns',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, email, department...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () { _searchController.clear(); setState(() => _query = ''); })
                    : null,
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty ? 'No interns assigned yet' : 'No results for "$_query"',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Text('${filtered.length} intern${filtered.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _InternCard(
                intern: filtered[index],
                onTap: () => _showInternDetails(filtered[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── keep all the helper widgets exactly as before ─────────────────────────────
class _InternCard extends StatelessWidget {
  final Intern intern;
  final VoidCallback onTap;
  const _InternCard({required this.intern, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2D3A8C).withOpacity(0.1),
              child: Text(intern.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF2D3A8C),
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(intern.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(intern.email,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text(intern.department.name,
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF))),
              ]),
            ),
            Column(children: [
              _StatusBadge(status: intern.status),
              const SizedBox(height: 6),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final isApproved = status == "Approved";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isApproved ? Colors.green : Colors.orange),
      ),
      child: Text(status,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: isApproved ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _DetailStat({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }
}