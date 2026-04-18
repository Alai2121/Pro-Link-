import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import 'admin_dashboard.dart';
import 'manage_interns.dart';
import 'upload_schedule.dart';
import '../models/admin.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignIntern extends StatefulWidget {
  final Admin admin;

  const AssignIntern({super.key, required this.admin});
  @override
  State<AssignIntern> createState() => _AssignInternState();
}

class _AssignInternState extends State<AssignIntern> {

  final TextEditingController internController = TextEditingController();
  final TextEditingController mentorController = TextEditingController();
  final TextEditingController deptController = TextEditingController();

  List<Map<String, String>> assignments = [];

  // ================= ASSIGN FUNCTION =================
  void assignIntern() {
    try {
      final intern = FakeData.interns
          .firstWhere((i) => i.id == internController.text);

      final mentor = FakeData.mentors
          .firstWhere((m) => m.id == mentorController.text);

      final dept = FakeData.departments
          .firstWhere((d) => d.id == deptController.text);

      setState(() {
        assignments.add({
          "internId": intern.id,
          "internName": intern.name,
          "mentorId": mentor.id,
          "mentorName": mentor.name,
          "deptName": dept.name,
        });

        internController.clear();
        mentorController.clear();
        deptController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid IDs ❌")),
      );
    }
  }

  // ================= DRAWER =================
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFA07A4E),
      child: Column(
        children: [

          const SizedBox(height: 50),

          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/admin.png"),
          ),

          const SizedBox(height: 10),

           Text(
             widget.admin.name,
            style: TextStyle(color: Colors.white,
                fontSize: 16,fontWeight: FontWeight.bold),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text("Dashboard",style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDashboard(admin: widget.admin),
                ),
                    (route) => false,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text("Manage Interns",style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageInterns(admin: widget.admin),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment_ind, color: Colors.white),
            title: const Text("Assign Interns",style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: const Text("Upload Schedule",style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadSchedule(admin: widget.admin),
                ),
              );
            },
          ),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Pro Link",
              style: GoogleFonts.playfairDisplay(
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

  // ================= GENERIC TABLE =================
  Widget buildTable(String title, List<String> columns, List<List<String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 15),

        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(12),
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              border: TableBorder.all(color: Colors.grey),

              headingRowColor:
              MaterialStateProperty.all(Colors.blue.shade100),

              columns: columns.map((c) => DataColumn(label: Text(c))).toList(),

              rows: rows.map((row) {
                return DataRow(
                  cells: row.map((cell) => DataCell(Text(cell))).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final approvedInterns = FakeData.interns
        .where((i) => i.status == "Approved")
        .toList();

    final mentors = FakeData.mentors;
    final departments = FakeData.departments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Interns"),
      ),

      drawer: buildDrawer(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            // ================= INPUTS =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: TextField(
                            controller: internController,
                            decoration: const InputDecoration(
                              labelText: "Intern ID",
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: mentorController,
                            decoration: const InputDecoration(
                              labelText: "Mentor ID",
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: deptController,
                            decoration: const InputDecoration(
                              labelText: "Department ID",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: assignIntern,
                        child: const Text("Assign"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TABLE 1
            buildTable(
              "Approved Interns",
              ["ID", "Name", "Email", "Department"],
              approvedInterns.map((i) => [
                i.id,
                i.name,
                i.email,
                i.department.name,
              ]).toList(),
            ),

            // TABLE 2 + 3 SIDE BY SIDE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: buildTable(
                    "Mentors",
                    ["ID", "Name", "Email"],
                    mentors.map((m) => [
                      m.id,
                      m.name,
                      m.email,
                    ]).toList(),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildTable(
                    "Departments",
                    ["ID", "Name"],
                    departments.map((d) => [
                      d.id,
                      d.name,
                    ]).toList(),
                  ),
                ),
              ],
            ),

            // TABLE 4
            buildTable(
              "Assignments",
              [
                "Intern ID",
                "Intern Name",
                "Mentor ID",
                "Mentor Name",
                "Department"
              ],
              assignments.map((a) => [
                a["internId"]!,
                a["internName"]!,
                a["mentorId"]!,
                a["mentorName"]!,
                a["deptName"]!,
              ]).toList(),
            ),
          ],
        ),
      ),
    );
  }
}