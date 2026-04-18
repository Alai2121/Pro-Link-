import 'person.dart';
import 'department.dart';

class Intern extends Person {
  Department department;
  String status;
  String mentorId;

   Intern({
    required String id,
    required String name,
    required String email,
    required this.department,
    required this.status,
    required this.mentorId,
    required super.image,
     required super.password,
  }) : super(
    id: id,
    name: name,
    email: email,
    role: "intern",
  );
}