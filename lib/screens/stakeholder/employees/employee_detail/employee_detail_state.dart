import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

class EmployeeDetailState extends Equatable {
  final Employee employee;
  final bool isLoading;
  final String? error;
  final String? userRole;

  const EmployeeDetailState({
    required this.employee,
    this.isLoading = false,
    this.error,
    this.userRole,
  });

  EmployeeDetailState copyWith({
    Employee? employee,
    bool? isLoading,
    String? error,
    String? userRole,
  }) {
    return EmployeeDetailState(
      employee: employee ?? this.employee,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [employee, isLoading, error, userRole];
} 