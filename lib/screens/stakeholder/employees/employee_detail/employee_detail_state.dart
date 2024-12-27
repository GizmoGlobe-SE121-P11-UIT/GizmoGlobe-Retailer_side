import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

class EmployeeDetailState extends Equatable {
  final Employee employee;
  final bool isLoading;
  final String? error;

  const EmployeeDetailState({
    required this.employee,
    this.isLoading = false,
    this.error,
  });

  EmployeeDetailState copyWith({
    Employee? employee,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeDetailState(
      employee: employee ?? this.employee,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [employee, isLoading, error];
} 