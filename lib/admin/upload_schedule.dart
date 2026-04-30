import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/admin.dart';

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

  // ================= API =================

  static const String baseUrl =
      "http://192.168.1.19/prolink/admin";

  // ================= CONTROLLERS =================

  String? selectedInternId;
  String? selectedDay;
  String selectedType = "Work";

  final TextEditingController timeController =
  TextEditingController();

  final TextEditingController policyController =
  TextEditingController();

  // ================= DATA =================

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ];

  final List<String> types = [
    "Work",
    "Training",
    "Meeting",
    "Review"
  ];

  List interns = [];
  List schedules = [];
  List policies = [];

  bool loading = true;

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

      final schedulesRes = await http.get(
        Uri.parse("$baseUrl/get_schedules.php"),
      );

      final policiesRes = await http.get(
        Uri.parse("$baseUrl/get_policies.php"),
      );

      setState(() {

        interns = jsonDecode(internsRes.body);

        schedules = jsonDecode(schedulesRes.body);

        policies = jsonDecode(policiesRes.body);

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e")),
      );
    }
  }

  // ================= APPROVED INTERNS =================

  List get approvedInterns {

    return interns.where((i) {

      return i["status"]
          .toString()
          .toLowerCase()
          .trim() == "approved";

    }).toList();
  }

  // ================= ADD SCHEDULE =================

  Future<void> addSchedule() async {

    if (selectedInternId == null ||
        selectedDay == null ||
        timeController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields ❌"),
        ),
      );

      return;
    }

    try {

      final response = await http.post(

        Uri.parse("$baseUrl/add_schedule.php"),

        headers: {
          "Content-Type": "application/json"
        },

        body: jsonEncode({

          "intern_id": selectedInternId.toString(),
          "day": selectedDay.toString(),
          "time": timeController.text.trim(),
          "type": selectedType

        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Schedule Added ✅"),
          ),
        );

        timeController.clear();

        selectedInternId = null;
        selectedDay = null;

        await loadData();

        setState(() {});

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Insert Failed ❌ ${response.body}",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
        ),
      );
    }
  }

  // ================= ADD / UPDATE POLICY =================

  Future<void> savePolicy() async {

    if (policyController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter policy ❌"),
        ),
      );

      return;
    }

    try {

      String title = "Company Policy";

      // اذا يوجد policy مسبقاً نستعمل نفس id
      String? id;

      if (policies.isNotEmpty) {

        id = policies[0]["id"];
      }

      final response = await http.post(

        Uri.parse("$baseUrl/upload_policy.php"),

        headers: {
          "Content-Type": "application/json"
        },

        body: jsonEncode({

          "id": id,
          "title": title,
          "description": policyController.text.trim()

        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        Navigator.pop(context);

        await loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Policy Saved ✅"),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed ❌"),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
        ),
      );
    }
  }

  // ================= POLICY DIALOG =================

  void showPolicyDialog() {

    if (policies.isNotEmpty) {

      policyController.text =
          policies[0]["description"] ?? "";
    }

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text(

            "Company Policy",

            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(

            controller: policyController,

            maxLines: 8,

            decoration: const InputDecoration(

              hintText: "Enter policy...",

              border: OutlineInputBorder(),
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3A8C),
              ),

              onPressed: savePolicy,

              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= DRAWER =================

  Widget buildDrawer() {

    return Drawer(

      backgroundColor: const Color(0xFF2D3A8C),

      child: Column(

        children: [

          const SizedBox(height: 50),

          const CircleAvatar(
            radius: 40,
            backgroundImage:
            AssetImage("assets/admin.png"),
          ),

          const SizedBox(height: 10),

          Text(

            widget.admin.name,

            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),

          const Divider(),

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

            onTap: () => Navigator.pushReplacement(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    AdminDashboard(admin: widget.admin),
              ),
            ),
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

            onTap: () => Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    ManageInterns(admin: widget.admin),
              ),
            ),
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

            onTap: () => Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    AssignIntern(admin: widget.admin),
              ),
            ),
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
              Navigator.pop(context);
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

            onTap: () => Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder: (_) => LoginPage(),
              ),
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

        border: Border.all(
          color: const Color(0xFF2D3A8C)
              .withOpacity(0.3),
        ),

        borderRadius: BorderRadius.circular(12),
      ),

      child: ClipRRect(

        borderRadius: BorderRadius.circular(12),

        child: SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          child: DataTable(

            headingRowColor:
            MaterialStateProperty.all(
              const Color(0xFF2D3A8C),
            ),

            columns: [

              DataColumn(
                label: Text(
                  "Intern",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  "Day",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  "Time",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  "Type",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
            ],

            rows: schedules.map<DataRow>((s) {

              return DataRow(

                cells: [

                  DataCell(
                    Text(
                      s["internName"].toString(),
                    ),
                  ),

                  DataCell(
                    Text(
                      s["day"].toString(),
                    ),
                  ),

                  DataCell(
                    Text(
                      s["time"].toString(),
                    ),
                  ),

                  DataCell(
                    Text(
                      s["type"].toString(),
                    ),
                  ),
                ],
              );

            }).toList(),
          ),
        ),
      ),
    );
  }

  // ================= POLICY VIEW =================

  Widget buildPolicies() {

    if (policies.isEmpty) {

      return const Text(
        "No policy added",
      );
    }

    final p = policies[0];

    return Card(

      child: ListTile(

        leading: const Icon(
          Icons.policy,
          color: Color(0xFF2D3A8C),
        ),

        title: Text(
          p["title"].toString(),
        ),

        subtitle: Padding(

          padding: const EdgeInsets.only(top: 8),

          child: Text(
            p["description"].toString(),
          ),
        ),
      ),
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

      body: loading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        padding: const EdgeInsets.all(12),

        child: Column(

          children: [

            DropdownButtonFormField<String>(

              value: selectedInternId,

              hint: const Text("Select Intern"),

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              items: approvedInterns
                  .map<DropdownMenuItem<String>>((i) {

                return DropdownMenuItem(

                  value: i["id"].toString(),

                  child: Text(
                    i["name"].toString(),
                  ),
                );

              }).toList(),

              onChanged: (v) {

                setState(() {
                  selectedInternId = v;
                });
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(

              value: selectedDay,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Day"),

              items: days.map((d) {

                return DropdownMenuItem(
                  value: d,
                  child: Text(d),
                );

              }).toList(),

              onChanged: (v) {

                setState(() {
                  selectedDay = v;
                });
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(

              value: selectedType,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              items: types.map((t) {

                return DropdownMenuItem(
                  value: t,
                  child: Text(t),
                );

              }).toList(),

              onChanged: (v) {

                setState(() {
                  selectedType = v!;
                });
              },
            ),

            const SizedBox(height: 10),

            TextField(

              controller: timeController,

              decoration: const InputDecoration(

                labelText: "Time",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFF2D3A8C),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed: addSchedule,

                child: const Text(

                  "Add Schedule",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildTable(),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFF2D3A8C),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed: showPolicyDialog,

                child: const Text(

                  "Add / Edit Policy",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(

              "Policy",

              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildPolicies(),
          ],
        ),
      ),
    );
  }
}