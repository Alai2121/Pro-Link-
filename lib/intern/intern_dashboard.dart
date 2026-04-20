import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intern.dart';
import 'schedule_page.dart';
import 'marks_page.dart';
import 'documents_page.dart';
import 'work_id_page.dart';
import '../../auth/login_page.dart';

class InternDashboard extends StatefulWidget {
  final Intern intern;
  const InternDashboard({super.key, required this.intern});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> {
  int selectedIndex = 0;

  final Color primary = const Color(0xFF2D3A8C);

  final List<String> titles = [
    "Home",
    "Work ID",
    "Schedule",
    "Marks",
    "Documents",
  ];

  void _onSelect(int index) {
    setState(() => selectedIndex = index);
    Navigator.pop(context);
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(intern: widget.intern),
      WorkIDPage(intern: widget.intern),
      SchedulePage(intern: widget.intern),
      MarksPage(intern: widget.intern),
      const DocumentsPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          titles[selectedIndex],
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: IconThemeData(color: primary),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [


            DrawerHeader(
              decoration: BoxDecoration(color: primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(widget.intern.image),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.intern.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.intern.department.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      _getIcon(index),
                      color: selectedIndex == index ? primary : Colors.grey,
                    ),
                    title: Text(
                      titles[index],
                      style: GoogleFonts.poppins(),
                    ),
                    selected: selectedIndex == index,
                    selectedTileColor: const Color(0xFFF4F6FF),
                    onTap: () => _onSelect(index),
                  );
                },
              ),
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),


      body: pages[selectedIndex],


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: "Work"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: "Marks"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Docs"),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.badge;
      case 2:
        return Icons.schedule;
      case 3:
        return Icons.grade;
      case 4:
        return Icons.folder;
      default:
        return Icons.menu;
    }
  }
}


class HomePage extends StatelessWidget {
  final Intern intern;
  const HomePage({super.key, required this.intern});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2D3A8C);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),

          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(intern.image),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    intern.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _row("Email", intern.email),
                _row("Department", intern.department.name),
                _row("Status", intern.status),
                _row("ID", intern.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
          Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}