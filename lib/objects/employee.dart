import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  String? employeeID;
  String employeeName;
  String email;
  String phoneNumber;
  RoleEnum role;

  Employee({
    this.employeeID,
    required this.employeeName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  Employee copyWith({
    String? employeeID,
    String? employeeName,
    String? email,
    String? phoneNumber,
    required RoleEnum role,

  }) {
    return Employee(
      employeeID: employeeID ?? this.employeeID,
      employeeName: employeeName ?? this.employeeName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeName': employeeName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.getName(),
    };
  }

  static Employee fromMap(String id, Map<String, dynamic> map) {
    return Employee(
      employeeID: id,
      employeeName: map['employeeName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: RoleEnum.values.firstWhere(
        (e) => e.getName().toLowerCase() == (map['role'] as String? ?? 'employee').toLowerCase(),
        orElse: () => RoleEnum.employee,
      ),
    );
  }
} 