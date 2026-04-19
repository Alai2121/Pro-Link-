import '../models/intern.dart';
import '../models/mentor.dart';
import '../models/admin.dart';
import '../models/department.dart';
import '../models/schedule.dart';
import '../models/attendance.dart';
import '../models/evaluation.dart';
import '../models/trainingFile.dart';

class FakeData {
  static List<Department> departments = [
    const Department(id: "d1", name: "IT"),
    const Department(id: "d2", name: "HR"),
    const Department(id: "d3", name: "Finance"),
  ];

  static List<Admin> admin = [
    Admin(
      id: "a1",
      name: "alai",
      email: "admin@prolink.com",
      image: "assets/admin.png",
      password: "aaaa",
    ),
    Admin(
      id: "a2",
      name: "nesrine",
      email: "admin2@prolink.com",
      image: "assets/admin.png",
      password: "bbbb",
    ),
    Admin(
      id: "a3",
      name: "douaa",
      email: "super@prolink.com",
      image: "assets/admin.png",
      password: "1234",
    ),
  ];

  static List<Intern> interns = [
    Intern(
      id: "1",
      name: "Ali",
      email: "ali@mail.com",
      department: departments[0],
      status: "Approved",
      mentorId: "m1",
      image: "assets/admin.png",
      password:"aaaa",
    ),
    Intern(
      id: "2",
      name: "Sara",
      email: "sara@mail.com",
      department: departments[1], // ✔ هنا صححناها
      status: "Pending",
      mentorId: "m2",
      image: "assets/admin.png",
      password:"aaaa",
    ),
    Intern(
      id: "3",
      name: "AlAi",
      email: "alAi@mail.com",
      department: departments[2],
      status: "Approved",
      mentorId: "m1",
      image: "assets/admin.png",
      password:"aaaa",
    ),

  ];

  static List<Mentor> mentors = [
    Mentor(
      id: "m1",
      name: "Mr Ahmed",
      email: "ahmed@mail.com",
      department: departments[0],
      image: "assets/admin.png",
      password:"aaaa",
    ),
    Mentor(
      id: "m2",
      name: "Mr Ali",
      email: "ali@mail.com",
      department: departments[1],
      image: "assets/admin.png",
      password:"aaaa",
    ),
  ];

  static List<Schedule> schedules = [];

  static List<Attendance> attendances = [];
  static List<Evaluation> evaluations = [];
  static List<TrainingFile> trainingFiles = [];

}

