import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/schedule.dart';
import 'admin_dashboard.dart';
import 'manage_interns.dart';
import 'assign_interns.dart';
import '../models/admin.dart';
class UploadSchedule extends StatefulWidget {
  final Admin admin;

  const UploadSchedule({super.key, required this.admin});
  @override
  State<UploadSchedule> createState() => _UploadScheduleState();
}

class _UploadScheduleState extends State<UploadSchedule> {

  final TextEditingController internController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String selectedType = "Schedule";

  // ================= ADD =================
  void addSchedule() {
    try {
      final intern = FakeData.interns
          .firstWhere((i) => i.id == internController.text);

      setState(() {
        FakeData.schedules.add(
          Schedule(
            id: DateTime.now().toString(),
            internId: intern.id,
            internName: intern.name,
            day: dayController.text,
            time: timeController.text,
            type: selectedType,
          ),
        );

        internController.clear();
        dayController.clear();
        timeController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Intern ID ❌")),
      );
    }
  }

  // ================= DRAWER =================
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          const SizedBox(height: 50),

          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/admin.png"),
          ),

          const SizedBox(height: 10),

           Text( widget.admin.name,
              style: TextStyle(fontWeight: FontWeight.bold)),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>  AdminDashboard(admin: widget.admin)),
                    (route) => false,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Manage Interns"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ManageInterns(admin: widget.admin)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment_ind, color: Colors.green),
            title: const Text("Assign Interns"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AssignIntern(admin: widget.admin)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.orange),
            title: const Text("Upload Schedule"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ================= TABLE =================
  Widget buildTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(color: Colors.grey),

          columns: const [
            DataColumn(label: Text("Intern")),
            DataColumn(label: Text("Day")),
            DataColumn(label: Text("Time")),
            DataColumn(label: Text("Type")),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Schedule / Policy"),
      ),

      drawer: buildDrawer(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            // ================= FORM =================
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
                            controller: dayController,
                            decoration: const InputDecoration(
                              labelText: "Day",
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: timeController,
                            decoration: const InputDecoration(
                              labelText: "Time",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: "Schedule",
                          child: Text("Schedule"),
                        ),
                        DropdownMenuItem(
                          value: "Policy",
                          child: Text("Policy"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: addSchedule,
                        child: const Text("Upload"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= TABLE =================
            buildTable(),
          ],
        ),
      ),
    );
  }
}