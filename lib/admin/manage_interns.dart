
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/admin.dart';
import '../models/department.dart';
import '../models/mentor.dart';

import '../../auth/login_page.dart';
import 'admin_dashboard.dart';
import 'assign_interns.dart';
import 'upload_schedule.dart';
import '../services/api_service.dart';
class ManageInterns extends StatefulWidget {
  final Admin admin;

  const ManageInterns({super.key, required this.admin});

  @override
  State<ManageInterns> createState() => _ManageInternsState();
}

class _ManageInternsState extends State<ManageInterns> {

  final Color mainColor = const Color(0xFF2D3A8C);

  // ================= BASE URL =================
  final String baseUrl = ApiService.adminUrl;

  // ================= DATA =================
  List interns = [];
  List mentors = [];
  List departments = [];

  bool isLoading = true;

  // ================= CONTROLLERS =================
  final TextEditingController mId = TextEditingController();
  final TextEditingController mName = TextEditingController();
  final TextEditingController mEmail = TextEditingController();
  final TextEditingController mPassword = TextEditingController();

  Map<String, dynamic>? selectedDept;

  final TextEditingController dId = TextEditingController();
  final TextEditingController dName = TextEditingController();

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

  // ================= UPDATE STATUS =================
  Future<void> updateStatus(String internId, String status) async {

    try {

      final res = await http.post(

        Uri.parse("$baseUrl/update_intern_status.php"),

        body: {

          "intern_id": internId,
          "status": status,
        },
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {

        await loadData();

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Status Updated",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= ADD MENTOR =================
  Future<void> addMentor() async {

    if (selectedDept == null) return;

    try {

      final res = await http.post(

        Uri.parse("$baseUrl/add_mentor.php"),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "id": mId.text,
          "name": mName.text,
          "email": mEmail.text,
          "password": mPassword.text,
          "department_id": selectedDept!["id"],
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {

        mId.clear();
        mName.clear();
        mEmail.clear();
        mPassword.clear();

        selectedDept = null;

        loadData();

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Mentor Added Successfully",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= ADD DEPARTMENT =================
  Future<void> addDepartment() async {

    try {

      final res = await http.post(

        Uri.parse("$baseUrl/add_department.php"),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "id": dId.text,
          "name": dName.text,
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {

        dId.clear();
        dName.clear();

        loadData();

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Department Added Successfully",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= STATUS DROPDOWN =================
  Widget statusDropdown(Map intern) {

    String value = intern["status"];

    Color color = value == "Approved"
        ? Colors.green
        : value == "Rejected"
        ? Colors.red
        : Colors.orange;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),

      child: DropdownButton<String>(

        value: value,

        underline: const SizedBox(),

        dropdownColor: Colors.white,

        items: const [

          DropdownMenuItem(
            value: "Pending",
            child: Text("Pending"),
          ),

          DropdownMenuItem(
            value: "Approved",
            child: Text("Approved"),
          ),

          DropdownMenuItem(
            value: "Rejected",
            child: Text("Rejected"),
          ),
        ],

        onChanged: (val) {

          if (val != null) {

            updateStatus(
              intern["id"].toString(),
              val,
            );
          }
        },
      ),
    );
  }

  // ================= INTERN TABLE =================
  Widget buildInternTable() {

    return buildTable(

      "Interns",

      ["Name", "Email", "Department", "Mentor", "Status"],

      interns.map((inr) {

        return [

          inr["name"],
          inr["email"],
          inr["department"]["name"],
          inr["mentorId"].toString(),
          statusDropdown(inr),
        ];

      }).toList(),
    );
  }

  // ================= ADD MENTOR FORM =================
  Widget buildAddMentor() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            Text(
              "Add Mentor",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),

            TextField(
              controller: mId,
              decoration: const InputDecoration(
                labelText: "ID",
              ),
            ),

            TextField(
              controller: mName,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            TextField(
              controller: mEmail,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: mPassword,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 10),

            DropdownButton<Map<String, dynamic>>(

              value: selectedDept,

              hint: const Text("Select Department"),

              isExpanded: true,

              items: departments.map<DropdownMenuItem<Map<String, dynamic>>>((d) {

                return DropdownMenuItem<Map<String, dynamic>>(

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

              onPressed: addMentor,

              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
              ),

              child: Text(
                "Add Mentor",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD DEPARTMENT =================
  Widget buildAddDepartment() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            Text(
              "Add Department",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),

            TextField(
              controller: dId,
              decoration: const InputDecoration(
                labelText: "ID",
              ),
            ),

            TextField(
              controller: dName,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(

              onPressed: addDepartment,

              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
              ),

              child: Text(
                "Add Department",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENTOR TABLE =================
  Widget buildMentorTable() {

    return buildTable(

      "Mentors",

      ["Name", "Email", "Department"],

      mentors.map((m) {

        return [

          m["name"],
          m["email"],
          m["department"]["name"],
        ];

      }).toList(),
    );
  }

  // ================= DEPARTMENT TABLE =================
  Widget buildDepartmentTable() {

    return buildTable(

      "Departments",

      ["ID", "Name"],

      departments.map((d) {

        return [

          d["id"],
          d["name"],
        ];

      }).toList(),
    );
  }

  // ================= TABLE =================
  Widget buildTable(

      String title,
      List<String> columns,
      List<List<dynamic>> rows,
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
              color: mainColor.withOpacity(0.3),
            ),

            borderRadius: BorderRadius.circular(12),
          ),

          child: ClipRRect(

            borderRadius: BorderRadius.circular(12),

            child: SingleChildScrollView(

              scrollDirection: Axis.horizontal,

              child: DataTable(

                headingRowColor:
                MaterialStateProperty.all(mainColor),

                columns: columns.map((c) {

                  return DataColumn(

                    label: Text(

                      c,

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  );

                }).toList(),

                rows: rows.map((row) {

                  return DataRow(

                    cells: row.map((cell) {

                      return DataCell(

                        cell is Widget
                            ? cell
                            : Text(cell.toString()),
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

    return Scaffold(

      appBar: AppBar(

        backgroundColor: mainColor,

        foregroundColor: Colors.white,

        title: Text(

          "Manage Interns",

          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(

        backgroundColor: mainColor,
        child: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 50),

            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.admin.image),
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

                    builder: (_) =>
                        AdminDashboard(
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

                "Manage interns/mentor/departement",

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

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        AssignIntern(
                          admin: widget.admin,
                        ),
                  ),
                );
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

                    builder: (_) =>
                        UploadSchedule(
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

            const SizedBox(height: 300),

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
      ),
      // ================= BODY =================
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            buildInternTable(),

            const SizedBox(height: 20),

            buildAddMentor(),

            buildMentorTable(),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: buildAddDepartment(),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildDepartmentTable(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}