import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/fake_data.dart';
import '../models/schedule.dart';
import '../models/admin.dart';
import '../models/policy.dart';

import 'admin_dashboard.dart';
import 'manage_interns.dart';
import 'assign_interns.dart';
import '../../auth/login_page.dart';

class UploadSchedule extends StatefulWidget {
  final Admin admin;

  const UploadSchedule({super.key, required this.admin});

  @override
  State<UploadSchedule> createState() => _UploadScheduleState();
}

class _UploadScheduleState extends State<UploadSchedule> {

  // ================= SCHEDULE =================
  String? selectedInternId;
  String? selectedDay;
  String selectedType = "Work";

  final TextEditingController timeController = TextEditingController();

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
  ];

  final List<String> types = [
    "Work", "Training", "Meeting", "Review"
  ];

  List get approvedInterns =>
      FakeData.interns.where((i) => i.status == "Approved").toList();

  // ================= ADD SCHEDULE =================
  void addSchedule() {
    if (selectedInternId == null ||
        selectedDay == null ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields ❌")),
      );
      return;
    }

    final intern = FakeData.interns
        .firstWhere((i) => i.id == selectedInternId);

    setState(() {
      FakeData.schedules.add(
        Schedule(
          id: DateTime.now().toString(),
          internId: intern.id,
          internName: intern.name,
          day: selectedDay!,
          time: timeController.text,
          type: selectedType,
        ),
      );

      timeController.clear();
    });
  }

  // ================= PICK PDF =================
  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        FakeData.policies.add(
          Policy(
            id: DateTime.now().toString(),
            title: result.files.single.name,
            description: result.files.single.path!,
          ),
        );
      });
    }
  }

  // ================= DRAWER =================
  Widget buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF2D3A8C),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/admin.png")),
          const SizedBox(height: 10),
          Text(widget.admin.name, style: GoogleFonts.poppins(color: Colors.white)),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: Text("Dashboard", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboard(admin: widget.admin)),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: Text("Manage interns/mentor/departemment", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ManageInterns(admin: widget.admin)),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.assignment_ind, color: Colors.white),
            title: Text("Assign Interns", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AssignIntern(admin: widget.admin)),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: Text("Upload Schedule", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: Text("Logout", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TABLE =================
  Widget buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2D3A8C).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
            MaterialStateProperty.all(const Color(0xFF2D3A8C)),
            columns: [
              DataColumn(label: Text("Intern", style: GoogleFonts.poppins(color: Colors.white))),
              DataColumn(label: Text("Day", style: GoogleFonts.poppins(color: Colors.white))),
              DataColumn(label: Text("Time", style: GoogleFonts.poppins(color: Colors.white))),
              DataColumn(label: Text("Type", style: GoogleFonts.poppins(color: Colors.white))),
            ],
            rows: FakeData.schedules.map((s) {
              return DataRow(cells: [
                DataCell(Text(s.internName)),
                DataCell(Text(s.day)),
                DataCell(Text(s.time)),
                DataCell(Text(s.type)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ================= POLICIES =================
  Widget buildPolicies() {
    if (FakeData.policies.isEmpty) {
      return const Text("No files uploaded");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: FakeData.policies.length,
      itemBuilder: (context, index) {
        final p = FakeData.policies[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(p.title),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
        title: Text(
          "Upload Schedule",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: buildDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              hint: const Text("Select Intern"),
              items: approvedInterns.map<DropdownMenuItem<String>>((i) {
                return DropdownMenuItem(value: i.id, child: Text(i.name));
              }).toList(),
              onChanged: (v) => setState(() => selectedInternId = v),
            ),

            DropdownButtonFormField<String>(
              hint: const Text("Select Day"),
              items: days.map((d) =>
                  DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => selectedDay = v),
            ),

            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((t) =>
                  DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            ),

            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "Time"),
            ),

            ElevatedButton(
              onPressed: addSchedule,
              child: const Text("Add Schedule"),
            ),

            const SizedBox(height: 20),

            buildTable(),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: pickPDF,
              child: const Text("Upload PDF"),
            ),

            const SizedBox(height: 20),

            Text(
              "Uploaded Policies",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),

            buildPolicies(),
          ],
        ),
      ),
    );
  }
}