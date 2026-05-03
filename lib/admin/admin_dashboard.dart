import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../../auth/login_page.dart';
import '../models/admin.dart';
import 'manage_interns.dart';
import 'assign_interns.dart';
import 'upload_schedule.dart';

class AdminDashboard extends StatefulWidget {
  final Admin admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  final String baseUrl = ApiService.adminUrl;

  DateTime currentDate = DateTime.now();

  TextEditingController searchController = TextEditingController();

  // ================= SEARCH DATA =================
  List _allInterns     = [];
  List _allMentors     = [];
  List _allDepartments = [];

  //  { "type": "intern"|"mentor"|"department", "data": Map }
  List<Map<String, dynamic>> searchResults = [];

  // ================= DASHBOARD DATA =================
  Map<String, dynamic> stats = {};
  List departments            = [];
  List pendingInterns         = [];
  bool isLoading              = true;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse("$baseUrl/get_dashboard_stats.php")),
        http.get(Uri.parse("$baseUrl/get_department_stats.php")),
        http.get(Uri.parse("$baseUrl/get_pending_interns.php")),
        http.get(Uri.parse("$baseUrl/get_all_interns.php")),
        http.get(Uri.parse("$baseUrl/get_all_mentors.php")),
        http.get(Uri.parse("$baseUrl/get_all_departments.php")),
      ]);

      setState(() {
        stats           = jsonDecode(results[0].body);
        departments     = jsonDecode(results[1].body);
        pendingInterns  = jsonDecode(results[2].body);
        _allInterns     = jsonDecode(results[3].body);
        _allMentors     = jsonDecode(results[4].body);
        _allDepartments = jsonDecode(results[5].body);
        isLoading       = false;
      });
    } catch (e) {
      debugPrint("loadData error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= SEARCH =================
  void onSearchChanged(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        searchResults = [];
        return;
      }

      final q = value.toLowerCase();
      final List<Map<String, dynamic>> results = [];

      // البحث في الـ interns
      for (final intern in _allInterns) {
        final name  = (intern["name"]  ?? "").toString().toLowerCase();
        final email = (intern["email"] ?? "").toString().toLowerCase();
        final dept  = (intern["department"]?["name"] ?? "").toString().toLowerCase();
        if (name.contains(q) || email.contains(q) || dept.contains(q)) {
          results.add({"type": "intern", "data": intern});
        }
      }

      // البحث في الـ mentors
      for (final mentor in _allMentors) {
        final name  = (mentor["name"]  ?? "").toString().toLowerCase();
        final email = (mentor["email"] ?? "").toString().toLowerCase();
        final dept  = (mentor["department"]?["name"] ?? "").toString().toLowerCase();
        if (name.contains(q) || email.contains(q) || dept.contains(q)) {
          results.add({"type": "mentor", "data": mentor});
        }
      }

      // البحث في الـ departments
      for (final dept in _allDepartments) {
        final name = (dept["name"] ?? "").toString().toLowerCase();
        final id   = (dept["id"]   ?? "").toString().toLowerCase();
        if (name.contains(q) || id.contains(q)) {
          results.add({"type": "department", "data": dept});
        }
      }

      searchResults = results;
    });
  }

  // ================= SHOW INFO CARD =================
  void showInfoCard(Map<String, dynamic> result) {
    final type = result["type"] as String;
    final data = result["data"] as Map<String, dynamic>;


       String mentorName = "";
    if (type == "intern" && data["mentorId"] != null && data["mentorId"].toString().isNotEmpty) {
      final mentorId = data["mentorId"].toString();
      final found = _allMentors.where((m) => m["id"].toString() == mentorId).toList();
      if (found.isNotEmpty) mentorName = found.first["name"].toString();
    }

        int deptInternCount = 0;
    if (type == "department") {
      deptInternCount = _allInterns
          .where((i) => i["department"]?["id"].toString() == data["id"].toString())
          .length;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3A8C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      type == "intern"
                          ? Icons.person
                          : type == "mentor"
                          ? Icons.supervisor_account
                          : Icons.business,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["name"] ?? (type == "department" ? data["name"] : ""),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            type == "intern"
                                ? "Intern"
                                : type == "mentor"
                                ? "Mentor"
                                : "Department",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Info rows ──
              if (type == "intern") ...[
                _infoRow(Icons.email,       "Email",      data["email"] ?? "—"),
                _infoRow(Icons.business,    "Department", data["department"]?["name"] ?? "—"),
                _infoRow(Icons.supervisor_account, "Mentor",
                    mentorName.isNotEmpty ? mentorName : "Not assigned"),
                _infoRow(Icons.info_outline, "Status",    data["status"] ?? "—",
                    valueColor: data["status"] == "Approved"
                        ? Colors.green
                        : data["status"] == "Rejected"
                        ? Colors.red
                        : Colors.orange),
              ],

              if (type == "mentor") ...[
                _infoRow(Icons.email,    "Email",      data["email"] ?? "—"),
                _infoRow(Icons.business, "Department", data["department"]?["name"] ?? "—"),
              ],

              if (type == "department") ...[
                _infoRow(Icons.tag,     "ID",      data["id"] ?? "—"),
                _infoRow(Icons.people,  "Interns", "$deptInternCount intern(s)"),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3A8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Close", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2D3A8C)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MONTH NAME =================
  String getMonthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  // ================= STAT CARD =================
  Widget statCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text("$count",
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= IMAGE CARD =================
  Widget buildImageCard(String image) {
    return SizedBox(
      height: 170,
      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(image, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ================= CALENDAR =================
  Widget buildCalendar() {
    DateTime firstDay = DateTime(currentDate.year, currentDate.month, 1);
    int startWeekday  = firstDay.weekday;
    int daysInMonth   = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    List<Widget> days = [];
    for (int i = 1; i < startWeekday; i++) days.add(const SizedBox());

    for (int i = 1; i <= daysInMonth; i++) {
      final day     = DateTime(currentDate.year, currentDate.month, i);
      final isToday = day.day == DateTime.now().day &&
          day.month == DateTime.now().month &&
          day.year  == DateTime.now().year;

      days.add(Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isToday ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text("$i",
              style: GoogleFonts.poppins(
                  fontSize: 8, color: isToday ? Colors.white : Colors.black)),
        ),
      ));
    }

    return SizedBox(
      height: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${getMonthName(currentDate.month)} ${currentDate.year}",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...["M","T","W","T","F","S","S"].map(
                          (e) => Center(child: Text(e, style: GoogleFonts.poppins(fontSize: 8))),
                    ),
                    ...days,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PIE CHART =================
  Widget buildPieChart() {
    final approved = stats["approved"] ?? 0;
    final pending  = stats["pending"]  ?? 0;
    final rejected = stats["rejected"] ?? 0;

    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text("Intern Status (Pie Chart)",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(PieChartData(sections: [
                        PieChartSectionData(value: approved.toDouble(), color: Colors.green, title: "", radius: 50),
                        PieChartSectionData(value: pending.toDouble(),  color: Colors.orange, title: "", radius: 50),
                        PieChartSectionData(value: rejected.toDouble(), color: Colors.red,    title: "", radius: 50),
                      ])),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        LegendItem(color: Colors.green,  text: "APP"),
                        LegendItem(color: Colors.orange, text: "PEN"),
                        LegendItem(color: Colors.red,    text: "REJ"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= BAR CHART =================
  Widget buildBarChart() {
    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text("Interns per Department",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Expanded(
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < departments.length) {
                            return Text(departments[index]["name"],
                                style: GoogleFonts.poppins(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(departments.length, (i) {
                    final dep = departments[i];
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: double.parse(dep["total"].toString()),
                        color: Colors.blue,
                        width: 18,
                      ),
                    ]);
                  }),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= REQUESTS =================
  Widget buildRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Registration Requests",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...pendingInterns.map((i) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(i["name"][0])),
            title: Text(i["name"]),
            subtitle: Text(i["email"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    final res = await http.post(
                      Uri.parse("$baseUrl/update_intern_status.php"),
                      body: {"intern_id": i["id"].toString(), "status": "Approved"},
                    );
                    final data = jsonDecode(res.body);
                    if (data["error"] == false) {
                      setState(() {
                        pendingInterns.remove(i);
                        stats["pending"]  = (stats["pending"]  ?? 1) - 1;
                        stats["approved"] = (stats["approved"] ?? 0) + 1;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    final res = await http.post(
                      Uri.parse("$baseUrl/update_intern_status.php"),
                      body: {"intern_id": i["id"].toString(), "status": "Rejected"},
                    );
                    final data = jsonDecode(res.body);
                    if (data["error"] == false) {
                      setState(() {
                        pendingInterns.remove(i);
                        stats["pending"]  = (stats["pending"]  ?? 1) - 1;
                        stats["rejected"] = (stats["rejected"] ?? 0) + 1;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  // ================= DRAWER =================
  Widget buildDrawer(Admin admin) {
    return Drawer(
      backgroundColor: const Color(0xFF2D3A8C),
        child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          CircleAvatar(radius: 40, backgroundImage: AssetImage(admin.image)),
          const SizedBox(height: 10),
          Text(admin.name,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: Text("Dashboard", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: Text("Manage interns/mentor/department",
                style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ManageInterns(admin: admin))),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind, color: Colors.white),
            title: Text("Assign Interns", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AssignIntern(admin: admin))),
          ),
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: Text("Upload Schedule", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => UploadSchedule(admin: admin))),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: Text("Logout", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => LoginPage())),
          ),
          const SizedBox(height: 300),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text("Pro Link",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
        ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final admin = widget.admin;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
        title: Row(
          children: [

            Flexible(
              flex: 2,
              child: Text(
                "Hi, ${admin.name}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              flex: 3,
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      drawer: buildDrawer(admin),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            // ── Stat Cards ──
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(width: 150, child: statCard("Interns",     stats["interns"]     ?? 0, Colors.blue)),
                SizedBox(width: 150, child: statCard("Pending",     stats["pending"]     ?? 0, Colors.orange)),
                SizedBox(width: 150, child: statCard("Approved",    stats["approved"]    ?? 0, Colors.green)),
                SizedBox(width: 150, child: statCard("Rejected",    stats["rejected"]    ?? 0, Colors.red)),
                SizedBox(width: 150, child: statCard("Mentors",     stats["mentors"]     ?? 0, Colors.purple)),
                SizedBox(width: 150, child: statCard("Departments", stats["departments"] ?? 0, Colors.teal)),
              ],
            ),

            // ── Search Results Dropdown ──
            if (searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  children: searchResults.map((result) {
                    final type = result["type"] as String;
                    final data = result["data"]  as Map<String, dynamic>;


                    final icon = type == "intern"
                        ? Icons.person
                        : type == "mentor"
                        ? Icons.supervisor_account
                        : Icons.business;


                    final badgeColor = type == "intern"
                        ? Colors.blue
                        : type == "mentor"
                        ? Colors.purple
                        : Colors.teal;

                    return ListTile(
                      leading: Icon(icon, color: badgeColor),
                      title: Text(
                        data["name"] ?? "",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        type == "department"
                            ? "Department"
                            : (data["email"] ?? ""),
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: badgeColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      onTap: () {

                        FocusScope.of(context).unfocus();
                        searchController.clear();
                        setState(() => searchResults = []);

                        showInfoCard(result);
                      },
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            // ── Image + Calendar ──
            Row(
              children: [
                Expanded(child: buildImageCard(admin.image)),
                const SizedBox(width: 10),
                Expanded(child: buildCalendar()),
              ],
            ),

            const SizedBox(height: 10),


            Row(
              children: [
                Expanded(child: buildBarChart()),
                const SizedBox(width: 10),
                Expanded(child: buildPieChart()),
              ],
            ),

            const SizedBox(height: 15),

            // ── Requests ──
            buildRequests(),
          ],
        ),
      ),
    );
  }
}

// ================= LEGEND =================
class LegendItem extends StatelessWidget {
  final Color  color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}