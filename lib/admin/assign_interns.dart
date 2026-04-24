import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/admin.dart';
import '../models/mentor.dart';
import '../models/department.dart';
import '../models/intern.dart';
import 'admin_dashboard.dart';
import 'manage_interns.dart';
import 'upload_schedule.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/login_page.dart';
class AssignIntern extends StatefulWidget {
  final Admin admin;

  const AssignIntern({super.key, required this.admin});

  @override
  State<AssignIntern> createState() => _AssignInternState();
}

class _AssignInternState extends State<AssignIntern> {

  // ================= SELECTED OBJECTS =================
  Intern? selectedIntern;
  Mentor? selectedMentor;
  Department? selectedDept;

  List<Map<String, String>> assignments = [];

  // ================= ASSIGN =================
  void assignIntern() {
    if (selectedIntern == null ||
        selectedMentor == null ||
        selectedDept == null) return;

    setState(() {
      // 🔥 تحديث Intern الحقيقي
      selectedIntern!.mentorId = selectedMentor!.id;
      selectedIntern!.department = selectedDept!;

      assignments.add({
        "internId": selectedIntern!.id,
        "internName": selectedIntern!.name,
        "mentorId": selectedMentor!.id,
        "mentorName": selectedMentor!.name,
        "deptName": selectedDept!.name,
      });

      selectedIntern = null;
      selectedMentor = null;
      selectedDept = null;
    });
  }

  // ================= TABLE =================
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
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              columns: columns
                  .map((c) => DataColumn(label: Text(c)))
                  .toList(),

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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    final approvedInterns = FakeData.interns
        .where((i) => i.status == "Approved")
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
        title: Text("Assign Interns",
          style: GoogleFonts.playfairDisplay(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF2D3A8C),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/admin.png")),
            const SizedBox(height: 10),
            Text(widget.admin.name,
                style: const TextStyle(color: Colors.white)),
            const Divider(color: Colors.white),


            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AdminDashboard(admin: widget.admin)));
              },
            ),

            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text("Manage interns/mentor/departemment", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ManageInterns(admin: widget.admin))),
            ),

            ListTile(
              leading: const Icon(Icons.assignment_ind, color: Colors.white),
              title: const Text("Assign Interns", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.white),
              title: const Text("Upload Schedule", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => UploadSchedule(admin: widget.admin)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout",style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LoginPage()));
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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            // ================= SELECTORS =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [

                    // INTERN
                    DropdownButton<Intern>(
                      value: selectedIntern,
                      hint: const Text("Select Intern"),
                      isExpanded: true,
                      items: approvedInterns.map((i) {
                        return DropdownMenuItem(
                          value: i,
                          child: Text(i.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedIntern = val);
                      },
                    ),

                    // MENTOR
                    DropdownButton<Mentor>(
                      value: selectedMentor,
                      hint: const Text("Select Mentor"),
                      isExpanded: true,
                      items: FakeData.mentors.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedMentor = val);
                      },
                    ),

                    // DEPARTMENT
                    DropdownButton<Department>(
                      value: selectedDept,
                      hint: const Text("Select Department"),
                      isExpanded: true,
                      items: FakeData.departments.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text(d.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedDept = val);
                      },
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: assignIntern,
                      child: const Text("Assign Intern"),
                    ),
                  ],
                ),
              ),
            ),

            // ================= TABLES =================

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

            Row(
              children: [

                Expanded(
                  child: buildTable(
                    "Mentors",
                    ["ID", "Name"],
                    FakeData.mentors.map((m) => [
                      m.id,
                      m.name,
                    ]).toList(),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildTable(
                    "Departments",
                    ["ID", "Name"],
                    FakeData.departments.map((d) => [
                      d.id,
                      d.name,
                    ]).toList(),
                  ),
                ),
              ],
            ),

            buildTable(
              "Assignments",
              ["Intern", "Mentor", "Department"],
              assignments.map((a) => [
                a["internName"]!,
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