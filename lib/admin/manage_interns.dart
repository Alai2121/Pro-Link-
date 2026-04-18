import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/fake_data.dart';
import 'admin_dashboard.dart';
import 'assign_interns.dart';
import 'upload_schedule.dart';
import '../models/admin.dart';

class ManageInterns extends StatefulWidget {
  final Admin admin;

  const ManageInterns({super.key, required this.admin});

  @override
  State<ManageInterns> createState() => _ManageInternsState();
}

class _ManageInternsState extends State<ManageInterns> {

  // ================= STATUS UPDATE =================
  void changeInternStatus(int index, String status) {
    setState(() {
      FakeData.interns[index].status = status;
    });
  }

  // ================= DRAWER =================
  Widget buildDrawer() {
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

          Text(widget.admin.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),

          const Divider(color: Colors.white),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text("Dashboard",
                style: TextStyle(color: Colors.white)),
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
            leading: const Icon(Icons.assignment_ind, color: Colors.white),
            title: const Text("Assign Interns",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignIntern(admin: widget.admin),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: const Text("Upload Schedule",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadSchedule(admin: widget.admin),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= STATUS DROPDOWN =================
  Widget statusDropdown(int index, String currentStatus) {
    Color color = Colors.grey;

    if (currentStatus == "Approved") color = Colors.green;
    if (currentStatus == "Rejected") color = Colors.red;
    if (currentStatus == "Pending") color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: currentStatus,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        items: const [
          DropdownMenuItem(value: "Pending", child: Text("Pending")),
          DropdownMenuItem(value: "Approved", child: Text("Approved")),
          DropdownMenuItem(value: "Rejected", child: Text("Rejected")),
        ],
        onChanged: (value) {
          if (value != null) {
            changeInternStatus(index, value);
          }
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
      interns.map((i) {
        int index = interns.indexOf(i);

        return [
          i.name,
          i.email,
          i.department.name,
          i.mentorId,
          statusDropdown(index, i.status),
        ];
      }).toList(),
    );
  }

  // ================= ADD MENTOR =================
  Widget buildAddMentorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: const [
            Text("Add Mentor", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "ID")),
            TextField(decoration: InputDecoration(labelText: "Name")),
            TextField(decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: null, child: Text("Add Mentor")),
          ],
        ),
      ),
    );
  }

  // ================= ADD DEPARTMENT =================
  Widget buildAddDepartmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: const [
            Text("Add Department",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "ID")),
            TextField(decoration: InputDecoration(labelText: "Name")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: null, child: Text("Add Department")),
          ],
        ),
      ),
    );
  }

  // ================= MENTORS TABLE =================
  Widget buildMentorTable() {
    return buildTable(
      "Mentors",
      ["Name", "Email", "Department"],
      FakeData.mentors.map((m) {
        return [m.name, m.email, m.department];
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

  // ================= TABLE UI =================
  Widget buildTable(String title, List<String> columns,
      List<List<dynamic>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 15),

        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA07A4E)),
            borderRadius: BorderRadius.circular(12),
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              headingRowColor:
              MaterialStateProperty.all(const Color(0xFFA07A4E)),

              columns: columns
                  .map((c) => DataColumn(
                  label: Text(c,
                      style: const TextStyle(color: Colors.white))))
                  .toList(),

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
        backgroundColor: const Color(0xFFA07A4E),
        title: Text(
          "Manage Data",
          style: GoogleFonts.playfairDisplay(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      drawer: buildDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            buildInternTable(),

            const SizedBox(height: 20),

            buildAddMentorCard(),
            buildMentorTable(),

            const SizedBox(height: 20),

            // 🔥 Department SIDE BY SIDE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(child: buildAddDepartmentCard()),

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