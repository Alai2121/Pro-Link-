import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  final String baseUrl = "http://192.168.100.4/prolink/admin";

  DateTime currentDate = DateTime.now();

  TextEditingController searchController = TextEditingController();

  String query = "";

  List<String> suggestions = [];

  // ================= DATABASE DATA =================
  Map<String, dynamic> stats = {};

  List departments = [];

  List pendingInterns = [];

  bool isLoading = true;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {

    try {

      final statsRes = await http.get(
        Uri.parse("$baseUrl/get_dashboard_stats.php"),
      );

      final deptRes = await http.get(
        Uri.parse("$baseUrl/get_department_stats.php"),
      );

      final pendingRes = await http.get(
        Uri.parse("$baseUrl/get_pending_interns.php"),
      );

      if (statsRes.statusCode == 200 &&
          deptRes.statusCode == 200 &&
          pendingRes.statusCode == 200) {

        setState(() {

          stats = jsonDecode(statsRes.body);

          departments = jsonDecode(deptRes.body);

          pendingInterns = jsonDecode(pendingRes.body);

          isLoading = false;
        });
      }

    } catch (e) {

      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= SEARCH =================
  void onSearchChanged(String value) {

    setState(() {

      query = value;

      List<String> allData = [

        "Training Modules",
        "Intern Records",
        "Company Policies",
        "Manage Interns",
        "Assign Interns",
        "Upload Schedule",

        ...pendingInterns.map((e) => e["name"].toString()),

        ...departments.map((e) => e["name"].toString()),
      ];

      if (value.isEmpty) {

        suggestions = [];

      } else {

        suggestions = allData
            .where((item) =>
            item.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  // ================= MONTH =================
  String getMonthName(int month) {

    const months = [

      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return months[month - 1];
  }

  // ================= STATS CARD =================
  Widget statCard(String title, int count, Color color) {

    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [

              Text(
                "$count",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= IMAGE =================
  Widget buildImageCard(String image) {

    return SizedBox(
      height: 170,

      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),

          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ================= CALENDAR =================
  Widget buildCalendar() {

    DateTime firstDay =
    DateTime(currentDate.year, currentDate.month, 1);

    int startWeekday = firstDay.weekday;

    int daysInMonth =
        DateTime(currentDate.year, currentDate.month + 1, 0).day;

    List<Widget> days = [];

    for (int i = 1; i < startWeekday; i++) {

      days.add(const SizedBox());
    }

    for (int i = 1; i <= daysInMonth; i++) {

      DateTime day =
      DateTime(currentDate.year, currentDate.month, i);

      bool isToday =
          day.day == DateTime.now().day &&
              day.month == DateTime.now().month &&
              day.year == DateTime.now().year;

      days.add(

        Container(
          margin: const EdgeInsets.all(1),

          decoration: BoxDecoration(
            color: isToday
                ? Colors.blue
                : Colors.grey.shade200,

            borderRadius: BorderRadius.circular(3),
          ),

          child: Center(
            child: Text(
              "$i",

              style: GoogleFonts.poppins(
                fontSize: 8,
                color: isToday
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      );
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

                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  children: [

                    ...["M", "T", "W", "T", "F", "S", "S"]
                        .map(
                          (e) => Center(
                        child: Text(
                          e,
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                          ),
                        ),
                      ),
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

    final pending = stats["pending"] ?? 0;

    final rejected = stats["rejected"] ?? 0;

    return SizedBox(

      height: 220,

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),

          child: Column(
            children: [

              Text(
                "Intern Status (Pie Chart)",

                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(
                child: Row(
                  children: [

                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [

                            PieChartSectionData(
                              value: approved.toDouble(),
                              color: Colors.green,
                              title: "",
                              radius: 50,
                            ),

                            PieChartSectionData(
                              value: pending.toDouble(),
                              color: Colors.orange,
                              title: "",
                              radius: 50,
                            ),

                            PieChartSectionData(
                              value: rejected.toDouble(),
                              color: Colors.red,
                              title: "",
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: const [

                        LegendItem(
                          color: Colors.green,
                          text: "Approved",
                        ),

                        LegendItem(
                          color: Colors.orange,
                          text: "Pending",
                        ),

                        LegendItem(
                          color: Colors.red,
                          text: "Rejected",
                        ),
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

              Text(
                "Interns per Department",

                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(
                child: BarChart(

                  BarChartData(

                    alignment:
                    BarChartAlignment.spaceAround,

                    titlesData: FlTitlesData(

                      rightTitles: const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),

                      topTitles: const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),

                      leftTitles: const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: true),
                      ),

                      bottomTitles: AxisTitles(

                        sideTitles: SideTitles(

                          showTitles: true,

                          getTitlesWidget: (value, meta) {

                            final index = value.toInt();

                            if (index < departments.length) {

                              return Text(

                                departments[index]["name"],

                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                ),
                              );
                            }

                            return const Text('');
                          },
                        ),
                      ),
                    ),

                    borderData:
                    FlBorderData(show: false),

                    barGroups:
                    List.generate(departments.length, (i) {

                      final dep = departments[i];

                      return BarChartGroupData(

                        x: i,

                        barRods: [

                          BarChartRodData(
                            toY: double.parse(
                                dep["total"].toString()),
                            color: Colors.blue,
                            width: 18,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
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

        Text(
          "Registration Requests",

          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...pendingInterns.map((i) => Card(

          child: ListTile(

            leading: CircleAvatar(
              child: Text(
                i["name"][0],
              ),
            ),

            title: Text(i["name"]),

            subtitle: Text(i["email"]),

            trailing: Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                IconButton(

                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),

                  onPressed: () async {

                    final res = await http.post(

                      Uri.parse("$baseUrl/update_intern_status.php"),

                      body: {

                        "intern_id": i["id"].toString(),
                        "status": "Approved",

                      },
                    );

                    final data = jsonDecode(res.body);

                    if (data["error"] == false) {

                      setState(() {

                        i["status"] = "Approved";

                        pendingInterns.remove(i);

                        stats["pending"] =
                            (stats["pending"] ?? 1) - 1;

                        stats["approved"] =
                            (stats["approved"] ?? 0) + 1;
                      });
                    }
                  },
                ),

                IconButton(

                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),

                  onPressed: () async {

                    final res = await http.post(

                      Uri.parse("$baseUrl/update_intern_status.php"),

                      body: {

                        "intern_id": i["id"].toString(),
                        "status": "Rejected",

                      },
                    );

                    final data = jsonDecode(res.body);

                    if (data["error"] == false) {

                      setState(() {

                        i["status"] = "Rejected";

                        pendingInterns.remove(i);

                        stats["pending"] =
                            (stats["pending"] ?? 1) - 1;

                        stats["rejected"] =
                            (stats["rejected"] ?? 0) + 1;
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

      child: Column(
        children: [

          const SizedBox(height: 50),

          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(admin.image),
          ),

          const SizedBox(height: 10),

          Text(
            admin.name,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          ListTile(
            leading:
            const Icon(Icons.dashboard, color: Colors.white),

            title: Text(
              "Dashboard",
              style:
              GoogleFonts.poppins(color: Colors.white),
            ),

            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading:
            const Icon(Icons.people, color: Colors.white),

            title: Text(
              "Manage interns/mentor/department",

              style:
              GoogleFonts.poppins(color: Colors.white),
            ),

            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      ManageInterns(admin: admin),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.assignment_ind,
              color: Colors.white,
            ),

            title: Text(
              "Assign Interns",

              style:
              GoogleFonts.poppins(color: Colors.white),
            ),

            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      AssignIntern(admin: admin),
                ),
              );
            },
          ),

          ListTile(
            leading:
            const Icon(Icons.schedule, color: Colors.white),

            title: Text(
              "Upload Schedule",

              style:
              GoogleFonts.poppins(color: Colors.white),
            ),

            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      UploadSchedule(admin: admin),
                ),
              );
            },
          ),

          ListTile(
            leading:
            const Icon(Icons.logout, color: Colors.white),

            title: Text(
              "Logout",

              style:
              GoogleFonts.poppins(color: Colors.white),
            ),

            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => LoginPage(),
                ),
              );
            },
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Text(

              "Pro Link",

              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    final admin = widget.admin;

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(

        backgroundColor: const Color(0xFF2D3A8C),

        foregroundColor: Colors.white,

        title: Row(
          children: [

            Text(

              "Hi, ${admin.name}",

              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(

                height: 40,

                child: TextField(

                  controller: searchController,

                  onChanged: onSearchChanged,

                  decoration: InputDecoration(

                    hintText: "Search...",

                    prefixIcon:
                    const Icon(Icons.search),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),

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

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Interns",
                    stats["interns"] ?? 0,
                    Colors.blue,
                  ),
                ),

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Pending",
                    stats["pending"] ?? 0,
                    Colors.orange,
                  ),
                ),

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Approved",
                    stats["approved"] ?? 0,
                    Colors.green,
                  ),
                ),

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Rejected",
                    stats["rejected"] ?? 0,
                    Colors.red,
                  ),
                ),

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Mentors",
                    stats["mentors"] ?? 0,
                    Colors.purple,
                  ),
                ),

                SizedBox(
                  width: 150,

                  child: statCard(
                    "Departments",
                    stats["departments"] ?? 0,
                    Colors.teal,
                  ),
                ),
              ],
            ),

            if (suggestions.isNotEmpty)

              Container(

                margin: const EdgeInsets.only(bottom: 10),

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(10),

                  boxShadow: const [

                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: Column(

                  children: suggestions.map((item) {

                    return ListTile(

                      title: Text(item),

                      leading:
                      const Icon(Icons.search),

                      onTap: () {

                        setState(() {

                          searchController.text = item;

                          suggestions = [];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: buildImageCard(admin.image),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildCalendar(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: buildBarChart(),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildPieChart(),
                ),
              ],
            ),

            const SizedBox(height: 15),

            buildRequests(),
          ],
        ),
      ),
    );
  }
}

// ================= LEGEND =================
class LegendItem extends StatelessWidget {

  final Color color;

  final String text;

  const LegendItem({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Container(
          width: 12,
          height: 12,
          color: color,
        ),

        const SizedBox(width: 5),

        Text(text),
      ],
    );
  }
}