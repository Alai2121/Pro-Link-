
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../models/admin.dart';

import 'admin_dashboard.dart';
import 'manage_interns.dart';
import 'upload_schedule.dart';

import '../../auth/login_page.dart';

class AssignIntern extends StatefulWidget {

  final Admin admin;

  const AssignIntern({
    super.key,
    required this.admin,
  });

  @override
  State<AssignIntern> createState() => _AssignInternState();
}

class _AssignInternState extends State<AssignIntern> {

  // ================= COLORS =================
  final Color mainColor = const Color(0xFF2D3A8C);

  // ================= BASE URL =================
  final String baseUrl =
      "http://192.168.1.15/prolink/admin";

  // ================= DATA =================
  List interns = [];

  List mentors = [];

  List departments = [];

  List assignments = [];

  bool isLoading = true;

  // ================= SELECTED =================
  Map<String, dynamic>? selectedIntern;

  Map<String, dynamic>? selectedMentor;

  Map<String, dynamic>? selectedDept;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    loadData();
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {

    try {

      final internsRes = await http.get(
        Uri.parse("$baseUrl/get_all_interns.php"),
      );

      final mentorsRes = await http.get(
        Uri.parse("$baseUrl/get_all_mentors.php"),
      );

      final departmentsRes = await http.get(
        Uri.parse("$baseUrl/get_all_departments.php"),
      );

      if (internsRes.statusCode == 200 &&
          mentorsRes.statusCode == 200 &&
          departmentsRes.statusCode == 200) {

        setState(() {

          interns = jsonDecode(internsRes.body);

          mentors = jsonDecode(mentorsRes.body);

          departments = jsonDecode(departmentsRes.body);

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

  // ================= ASSIGN INTERN =================
  Future<void> assignIntern() async {

    if (selectedIntern == null ||
        selectedMentor == null ||
        selectedDept == null) {

      return;
    }

    try {

      final res = await http.post(

        Uri.parse("$baseUrl/assign_intern.php"),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "intern_id": selectedIntern!["id"],

          "mentor_id": selectedMentor!["id"],

          "department_id": selectedDept!["id"],
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {

        setState(() {

          assignments.add({

            "internName": selectedIntern!["name"],

            "mentorName": selectedMentor!["name"],

            "deptName": selectedDept!["name"],
          });

          selectedIntern = null;

          selectedMentor = null;

          selectedDept = null;
        });

        await loadData();

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            backgroundColor: Colors.green,

            content: Text(

              "Intern Assigned Successfully",

              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= TABLE =================
  Widget buildTable(

      String title,
      List<String> columns,
      List<List<String>> rows,
      ) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const SizedBox(height: 15),

        Text(

          title,

          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Container(

          decoration: BoxDecoration(

            border: Border.all(
              color: Colors.grey.shade300,
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: ClipRRect(

            borderRadius: BorderRadius.circular(12),

            child: SingleChildScrollView(

              scrollDirection: Axis.horizontal,

              child: DataTable(

                columns: columns.map((c) {

                  return DataColumn(
                    label: Text(c),
                  );

                }).toList(),

                rows: rows.map((row) {

                  return DataRow(

                    cells: row.map((cell) {

                      return DataCell(
                        Text(cell),
                      );

                    }).toList(),
                  );

                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final approvedInterns = interns
        .where((i) => i["status"] == "Approved")
        .toList();

    return Scaffold(

      appBar: AppBar(

        backgroundColor: mainColor,

        foregroundColor: Colors.white,

        title: Text(

          "Assign Interns",

          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(

        backgroundColor: mainColor,

        child: Column(
          children: [

            const SizedBox(height: 50),

            CircleAvatar(
              radius: 40,
              backgroundImage:
              AssetImage(widget.admin.image),
            ),

            const SizedBox(height: 10),

            Text(

              widget.admin.name,

              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),

            const Divider(color: Colors.white),

            ListTile(

              leading: const Icon(
                Icons.dashboard,
                color: Colors.white,
              ),

              title: Text(

                "Dashboard",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => AdminDashboard(
                      admin: widget.admin,
                    ),
                  ),
                );
              },
            ),

            ListTile(

              leading: const Icon(
                Icons.people,
                color: Colors.white,
              ),

              title: Text(

                "Manage interns/mentor/departemment",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => ManageInterns(
                      admin: widget.admin,
                    ),
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

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),

              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(

              leading: const Icon(
                Icons.schedule,
                color: Colors.white,
              ),

              title: Text(

                "Upload Schedule",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => UploadSchedule(
                      admin: widget.admin,
                    ),
                  ),
                );
              },
            ),

            ListTile(

              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),

              title: Text(

                "Logout",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
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
      ),

      // ================= BODY =================
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            // ================= ASSIGN CARD =================
            Card(

              child: Padding(

                padding: const EdgeInsets.all(12),

                child: Column(
                  children: [

                    // ================= INTERN =================
                    DropdownButton<Map<String, dynamic>>(

                      value: selectedIntern,

                      hint: const Text("Select Intern"),

                      isExpanded: true,

                      items: approvedInterns
                          .map<DropdownMenuItem<Map<String, dynamic>>>((i) {

                        return DropdownMenuItem(

                          value: i,

                          child: Text(i["name"]),
                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {
                          selectedIntern = val;
                        });
                      },
                    ),

                    // ================= MENTOR =================
                    DropdownButton<Map<String, dynamic>>(

                      value: selectedMentor,

                      hint: const Text("Select Mentor"),

                      isExpanded: true,

                      items: mentors
                          .map<DropdownMenuItem<Map<String, dynamic>>>((m) {

                        return DropdownMenuItem(

                          value: m,

                          child: Text(m["name"]),
                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {
                          selectedMentor = val;
                        });
                      },
                    ),

                    // ================= DEPARTMENT =================
                    DropdownButton<Map<String, dynamic>>(

                      value: selectedDept,

                      hint: const Text("Select Department"),

                      isExpanded: true,

                      items: departments
                          .map<DropdownMenuItem<Map<String, dynamic>>>((d) {

                        return DropdownMenuItem(

                          value: d,

                          child: Text(d["name"]),
                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {
                          selectedDept = val;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(

                      onPressed: assignIntern,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),

                      child: Text(

                        "Assign Intern",

                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= APPROVED INTERNS =================
            buildTable(

              "Approved Interns",

              ["ID", "Name", "Email", "Department"],

              approvedInterns.map<List<String>>((i) {

                return [

                  i["id"].toString(),

                  i["name"],

                  i["email"],

                  i["department"]["name"],
                ];

              }).toList(),
            ),

            // ================= MENTORS + DEPARTMENTS =================
            Row(
              children: [

                Expanded(

                  child: buildTable(

                    "Mentors",

                    ["ID", "Name"],

                    mentors.map<List<String>>((m) {

                      return [

                        m["id"].toString(),

                        m["name"],
                      ];

                    }).toList(),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: buildTable(

                    "Departments",

                    ["ID", "Name"],

                    departments.map<List<String>>((d) {

                      return [

                        d["id"].toString(),

                        d["name"],
                      ];

                    }).toList(),
                  ),
                ),
              ],
            ),

            // ================= ASSIGNMENTS =================
            buildTable(

              "Assignments",

              ["Intern", "Mentor", "Department"],

              assignments.map<List<String>>((a) {

                return [

                  a["internName"],

                  a["mentorName"],

                  a["deptName"],
                ];

              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}