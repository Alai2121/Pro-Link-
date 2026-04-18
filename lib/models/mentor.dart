import 'person.dart';
import 'department.dart';

class Mentor extends Person {
  final Department department;

  Mentor({
    required String id,
    required String name,
    required String email,
    required this.department,
    required super.image,
    required super.password,
  }) : super(
    id: id,
    name: name,
    email: email,
    role: "mentor",
  );
}