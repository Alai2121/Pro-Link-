import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/fake_data.dart';
import '../models/admin.dart';
import '../models/department.dart';
import '../models/mentor.dart';

import 'admin_dashboard.dart';
import 'assign_interns.dart';
import 'upload_schedule.dart';
import '../../auth/login_page.dart';
class ManageInterns extends StatefulWidget {
  final Admin admin;

  const ManageInterns({super.key, required this.admin});

  @override
  State<ManageInterns> createState() => _ManageInternsState();
}

class _ManageInternsState extends State<ManageInterns> {

  final Color mainColor = const Color(0xFF2D3A8C);

  // ================= CONTROLLERS =================
  final TextEditingController mId = TextEditingController();
  final TextEditingController mName = TextEditingController();
  final TextEditingController mEmail = TextEditingController();
  final TextEditingController mPassword = TextEditingController();

  Department? selectedDept;

  final TextEditingController dId = TextEditingController();
  final TextEditingController dName = TextEditingController();

  // ================= STATUS =================
  void changeStatus(int index, String status) {
    setState(() {
      FakeData.interns[index].status = status;
    });
  }

  // ================= ADD MENTOR =================
  void addMentor() {
    if (selectedDept == null) return;

    setState(() {
      FakeData.mentors.add(
        Mentor(
          id: mId.text,
          name: mName.text,
          email: mEmail.text,
          password: mPassword.text,
          image: "assets/default.png",
          department: selectedDept!,
        ),
      );
    });

    mId.clear();
    mName.clear();
    mEmail.clear();
    mPassword.clear();
    selectedDept = null;
  }

  // ================= ADD DEPARTMENT =================
  void addDepartment() {
    setState(() {
      FakeData.departments.add(
        Department(
          id: dId.text,
          name: dName.text,
        ),
      );
    });

    dId.clear();
    dName.clear();
  }

  // ================= STATUS DROPDOWN =================
  Widget statusDropdown(int index, String value) {
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
          DropdownMenuItem(value: "Pending", child: Text("Pending")),
          DropdownMenuItem(value: "Approved", child: Text("Approved")),
          DropdownMenuItem(value: "Rejected", child: Text("Rejected")),
        ],
        onChanged: (val) {
          if (val != null) changeStatus(index, val);
        },
      ),
    );
  }

  // ================= INTERN TABLE =================
  Widget buildInternTable() {
    final interns = FakeData.interns;

    return buildTable(
      "Interns",
      ["Name", "Email", "Department", "Mentor", "Status"],
      interns.asMap().entries.map((entry) {
        int i = entry.key;
        var inr = entry.value;

        return [
          inr.name,
          inr.email,
          inr.department.name,
          inr.mentorId,
          statusDropdown(i, inr.status),
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

            const Text("Add Mentor",
                style: TextStyle(fontWeight: FontWeight.bold)),

            TextField(controller: mId, decoration: const InputDecoration(labelText: "ID")),
            TextField(controller: mName, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: mEmail, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: mPassword, decoration: const InputDecoration(labelText: "Password")),

            const SizedBox(height: 10),

            // 🔥 DROPDOWN DEPARTMENT (OBJECT)
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
                setState(() {
                  selectedDept = val;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addMentor,
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: const Text("Add Mentor",style: const TextStyle(color: Colors.white)),
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

            const Text("Add Department",
                style: TextStyle(fontWeight: FontWeight.bold)),

            TextField(controller: dId, decoration: const InputDecoration(labelText: "ID")),
            TextField(controller: dName, decoration: const InputDecoration(labelText: "Name")),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addDepartment,
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: const Text("Add Department",style: const TextStyle(color: Colors.white)),
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
      FakeData.mentors.map((m) {
        return [m.name, m.email, m.department.name];
      }).toList(),
    );
  }

  // ================= DEPARTMENT TABLE =================
  Widget buildDepartmentTable() {
    return buildTable(
      "Departments",
      ["ID", "Name"],
      FakeData.departments.map((d) {
        return [d.id, d.name];
      }).toList(),
    );
  }

  // ================= TABLE =================
  Widget buildTable(String title, List<String> columns, List<List<dynamic>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 15),

        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: mainColor),
            borderRadius: BorderRadius.circular(12),
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              headingRowColor: MaterialStateProperty.all(mainColor),

              columns: columns.map((c) {
                return DataColumn(
                  label: Text(c, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),

              rows: rows.map((row) {
                return DataRow(
                  cells: row.map((cell) {
                    return DataCell(
                      cell is Widget ? cell : Text(cell.toString()),
                    );
                  }).toList(),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        title: Text(
          "Manage Interns",
          style: GoogleFonts.playfairDisplay(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
// --------------------------drawer
      drawer: Drawer(
        backgroundColor: mainColor,
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
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.assignment_ind, color: Colors.white),
              title: const Text("Assign Interns", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AssignIntern(admin: widget.admin)));
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

            buildInternTable(),
            const SizedBox(height: 20),

            buildAddMentor(),
            buildMentorTable(),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: buildAddDepartment()),
                const SizedBox(width: 10),
                Expanded(child: buildDepartmentTable()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
