import 'package:flutter/material.dart';
import '../../models/intern.dart';

class WorkIDPage extends StatelessWidget {
  final Intern intern;
  const WorkIDPage({super.key, required this.intern});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ================= IMAGE =================
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage(intern.image),
                backgroundColor: Colors.grey.shade200,
              ),

              const SizedBox(height: 15),

              Text(
                intern.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A8C),
                ),
              ),

              Text(
                "Intern ID Card",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 25),

              _info("ID", intern.id),
              _info("Email", intern.email),
              _info("Department", intern.department.name),
              _info("Status", intern.status.toUpperCase()),
              _info(
                "Mentor ID",
                intern.mentorId.isEmpty ? "Not assigned" : intern.mentorId,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3A8C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}