import 'person.dart';

class Admin extends Person {
  Admin({
    required super.id,
    required super.name,
    required super.email,
    required super.image,
    required super.password,
  }) : super(role: "admin");
}