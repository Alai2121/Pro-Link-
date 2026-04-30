import '../models/intern.dart';
import '../models/mentor.dart';
import '../models/admin.dart';
import '../models/department.dart';
import '../models/schedule.dart';
import '../models/attendance.dart';
import '../models/evaluation.dart';
import '../models/trainingFile.dart';
import '../models/policy.dart';
class FakeData {

  static List<Policy> policies = [];
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
      name: "nesrine",
      email: "nesrine@mail.com",
      department: departments[0],
      status: "Approved",
      mentorId: "m1",
      image: "assets/student1.png",
      password: "aaaa",
    ),
    Intern(
      id: "2",
      name: "Sara",
      email: "sara@mail.com",
      department: departments[1],
      status: "Pending",
      mentorId: "m2",
      image: "assets/admin.png",
      password: "aaaa",
    ),
    Intern(
      id: "3",
      name: "AlAi",
      email: "alAi@mail.com",
      department: departments[2],
      status: "Approved",
      mentorId: "m1",
      image: "assets/admin.png",
      password: "aaaa",
    ),
  ];

  static List<Mentor> mentors = [
    Mentor(
      id: "m1",
      name: "Mr Ahmed",
      email: "ahmed@mail.com",
      department: departments[0],
      image: "assets/admin.png",
      password: "aaaa",
    ),
    Mentor(
      id: "m2",
      name: "Mr Ali",
      email: "ali@mail.com",
      department: departments[1],
      image: "assets/admin.png",
      password: "aaaa",
    ),
  ];

  // ================= SCHEDULE FIXED =================
  static List<Schedule> schedules = [
    const Schedule(
      id: "s1",
      internId: "1",
      internName: "nesrine",
      day: "Monday",
      time: "9:00 AM - 12:00 PM",
      type: "Work",
    ),
    const Schedule(
      id: "s2",
      internId: "1",
      internName: "nesrine",
      day: "Monday",
      time: "1:00 PM - 4:00 PM",
      type: "Training",
    ),
    const Schedule(
      id: "s3",
      internId: "1",
      internName: "nesrine",
      day: "Tuesday",
      time: "10:00 AM - 1:00 PM",
      type: "Meeting",
    ),
    const Schedule(
      id: "s4",
      internId: "1",
      internName: "nesrine",
      day: "Wednesday",
      time: "9:00 AM - 12:00 PM",
      type: "Work",
    ),
    const Schedule(
      id: "s5",
      internId: "1",
      internName: "nesrine",
      day: "Thursday",
      time: "10:00 AM - 1:00 PM",
      type: "Training",
    ),
    const Schedule(
      id: "s6",
      internId: "1",
      internName: "nesrine",
      day: "Friday",
      time: "9:00 AM - 12:00 PM",
      type: "Review",
    ),
  ];

  static List<Attendance> attendances = [];

  static List<Evaluation> evaluations = [
    const Evaluation(id: "e1", internId: "1", skill: "Communication", mark: 15),
    const Evaluation(id: "e2", internId: "1", skill: "Technical", mark: 18),
    const Evaluation(id: "e3", internId: "1", skill: "Teamwork", mark: 20),
    const Evaluation(id: "e4", internId: "1", skill: "Problem Solving", mark: 18),
    const Evaluation(id: "e5", internId: "1", skill: "Creativity", mark: 10),
  ];

  static List<TrainingFile> trainingFiles = [
    const TrainingFile(
      id: "f1",
      title: "Flutter Guide.pdf",
      fileUrl: "https://example.com/files/flutter_guide.pdf",
      mentorId: "m1",

    ),
    const TrainingFile(
      id: "f2",
      title: "Company Policy.docx",
      fileUrl: "https://example.com/files/company_policy.docx",
      mentorId: "m1",

    ),
  ];
}