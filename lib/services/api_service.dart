import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/intern.dart';
import '../models/mentor.dart';
import '../models/admin.dart';
import '../models/attendance.dart';
import '../models/evaluation.dart';
import '../models/trainingFile.dart';
import '../models/department.dart';
import '../models/schedule.dart';
import '../models/policy.dart';

class ApiService {
  static const String _ip = "192.168.100.4"; // ⚠️ change this
  static const String baseUrl = "http://$_ip/prolink";
  static const String adminUrl = "http://$_ip/prolink/admin";
  // Helper for mentor routes
  static String mentorUrl(String path) => "$baseUrl/mentor/$path";

  // ─── Login ────────────────────────────────────────────────
  static Future<dynamic> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {"email": email, "password": password},
      );
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body);
      if (data["error"] == true) return data["message"];
      return _parseUser(data["user"]);
    } catch (e) {
      return null;
    }
  }

  static dynamic _parseUser(Map<String, dynamic> u) {
    final role = u["role"];

    if (role == "admin") {
      return Admin(
        id: u["id"],
        name: u["name"],
        email: u["email"],
        password: u["password"],
        image: u["image"],
      );
    } else if (role == "mentor") {
      return Mentor(
        id: u["id"],
        name: u["name"],
        email: u["email"],
        password: u["password"],
        image: u["image"],
        department: Department(
          id: u["department"]["id"],
          name: u["department"]["name"],
        ),
      );
    } else if (role == "intern") {
      return Intern(
        id: u["id"],
        name: u["name"],
        email: u["email"],
        password: u["password"],
        image: u["image"],
        status: u["status"],
        mentorId: u["mentorId"],
        department: Department(
          id: u["department"]["id"],
          name: u["department"]["name"],
        ),
      );
    }
    return null;
  }

  // ─── Register ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {"name": name, "email": email, "password": password},
      );
      if (res.statusCode != 200) {
        return {"error": true, "message": "Server error."};
      }
      return json.decode(res.body);
    } catch (e) {
      return {"error": true, "message": "Network error."};
    }
  }

  // ─── Admin: Get ALL interns ───────────────────────────────
  static Future<List<Intern>> getAllInterns() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_all_interns.php"));
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseInternJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateInternStatus(
      String internId, String status) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update_intern_status.php"),
        body: {"intern_id": internId, "status": status},
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> assignMentor(
      String internId, String mentorId) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/assign_mentor.php"),
        body: {"intern_id": internId, "mentor_id": mentorId},
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Mentor>> getAllMentors() async {
    try {
      final res =
      await http.get(Uri.parse("$baseUrl/get_all_mentors.php"));
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data
          .map((j) => Mentor(
        id: j["id"],
        name: j["name"],
        email: j["email"],
        password: j["password"] ?? "",
        image: j["image"] ?? "assets/admin.png",
        department: Department(
          id: j["department"]["id"],
          name: j["department"]["name"],
        ),
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Mentor ───────────────────────────────────────────────
  static Future<List<Intern>> getMyInterns(String mentorId) async {
    try {
      final res = await http.get(
        Uri.parse(mentorUrl("get_my_interns.php?mentor_id=$mentorId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseInternJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveAttendance(
      String internId, String date, bool isPresent) async {
    try {
      final res = await http.post(
        Uri.parse(mentorUrl("save_attendance.php")),
        body: {
          "intern_id": internId,
          "date": date,
          "is_present": isPresent ? "1" : "0",
        },
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Attendance>> getAttendance(String mentorId) async {
    try {
      final res = await http.get(
        Uri.parse(mentorUrl("get_attendance.php?mentor_id=$mentorId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseAttendanceJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Attendance>> getMyAttendance(String internId) async {
    try {
      final res = await http.get(
        Uri.parse(mentorUrl("get_attendance.php?intern_id=$internId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseAttendanceJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveMark(
      String internId, String skill, int mark) async {
    try {
      final res = await http.post(
        Uri.parse(mentorUrl("save_mark.php")),
        body: {
          "intern_id": internId,
          "skill": skill,
          "mark": mark.toString(),
        },
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Evaluation>> getMarks(String mentorId) async {
    try {
      final res = await http.get(
        Uri.parse(mentorUrl("get_marks.php?mentor_id=$mentorId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseEvaluationJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Evaluation>> getMyMarks(String internId) async {
    try {
      final res = await http.get(
        Uri.parse(mentorUrl("get_marks.php?intern_id=$internId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data.map((j) => _parseEvaluationJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<TrainingFile>> getTrainingFiles(
      String mentorId) async {
    try {
      final res = await http.get(
        Uri.parse(
            mentorUrl("get_training_files.php?mentor_id=$mentorId")),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data
          .map((j) => TrainingFile(
        id: j["id"],
        title: j["title"],
        fileUrl: j["fileUrl"],
        mentorId: j["mentorId"],
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String?> addTrainingFile(
      String mentorId, String title, String fileUrl) async {
    try {
      final res = await http.post(
        Uri.parse(mentorUrl("training_files.php")),
        body: {
          "action": "add",
          "mentor_id": mentorId,
          "title": title,
          "file_url": fileUrl,
        },
      );
      final data = json.decode(res.body);
      if (data["error"] == false) return data["id"];
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteTrainingFile(String fileId) async {
    try {
      final res = await http.post(
        Uri.parse(mentorUrl("training_files.php")),
        body: {"action": "delete", "file_id": fileId},
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  // ─── Update mentor profile picture (URL-based) ────────────
  static Future<String?> updateMentorProfileImage(
      String mentorId,
      String imagePath,
      ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(mentorUrl("update_mentor_profile.php")),
      );

      request.fields['mentor_id'] = mentorId;
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is Map && data["error"] == false) {
        return data["image_path"];
      }
      return null;
    } catch (e) {
      print('UPLOAD EXCEPTION: $e');
      return null;
    }
  }

  // ─── Schedules ────────────────────────────────────────────
  static Future<List<Schedule>> getSchedules(String internId) async {
    try {
      final res = await http.get(
        Uri.parse(
            "$baseUrl/interns/get_schedules.php?intern_id=$internId"),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data
          .map((j) => Schedule(
        id: j["id"],
        internId: j["internId"],
        internName: j["internName"],
        day: j["day"],
        time: j["time"],
        type: j["type"],
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addSchedule(Schedule s) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add_schedule.php"),
        body: {
          "intern_id": s.internId,
          "intern_name": s.internName,
          "day": s.day,
          "time": s.time,
          "type": s.type,
        },
      );
      final data = json.decode(res.body);
      return data["error"] == false;
    } catch (e) {
      return false;
    }
  }

  // ─── Policies ─────────────────────────────────────────────
  static Future<List<Policy>> getPolicies() async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/interns/get_policies.php"));
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data
          .map((j) => Policy(
        id: j["id"],
        title: j["title"],
        description: j["description"],
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Private helpers ──────────────────────────────────────
  static Intern _parseInternJson(Map<String, dynamic> j) {
    return Intern(
      id: j["id"],
      name: j["name"],
      email: j["email"],
      password: j["password"] ?? "",
      image: j["image"] ?? "assets/admin.png",
      status: j["status"],
      mentorId: j["mentorId"],
      department: Department(
        id: j["department"]["id"],
        name: j["department"]["name"],
      ),
    );
  }

  static Attendance _parseAttendanceJson(Map<String, dynamic> j) {
    return Attendance(
      id: j["id"],
      internId: j["internId"],
      date: j["date"],
      isPresent: j["isPresent"] == "1" ||
          j["isPresent"] == 1 ||
          j["isPresent"] == true,
    );
  }

  static Evaluation _parseEvaluationJson(Map<String, dynamic> j) {
    return Evaluation(
      id: j["id"],
      internId: j["internId"],
      skill: j["skill"],
      mark: int.parse(j["mark"].toString()),
    );
  }

  static Future<List<TrainingFile>> getMyTrainingFiles(
      String mentorId) async {
    try {
      final res = await http.get(
        Uri.parse(
            "$baseUrl/interns/get_training_files.php?mentor_id=$mentorId"),
      );
      if (res.statusCode != 200) return [];
      final List data = json.decode(res.body);
      return data
          .map((j) => TrainingFile(
        id: j["id"],
        title: j["title"],
        fileUrl: j["fileUrl"],
        mentorId: j["mentorId"],
      ))
          .toList();
    } catch (e) {
      return [];
    }
  }
}