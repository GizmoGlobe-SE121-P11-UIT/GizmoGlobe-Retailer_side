import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

class EmployeesScreenState extends Equatable {
  final List<Employee> employees;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;
  final RoleEnum? selectedRoleFilter;
  final String? userRole;

  const EmployeesScreenState({
    this.employees = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
    this.selectedRoleFilter,
    this.userRole,
  });

  EmployeesScreenState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
    RoleEnum? selectedRoleFilter,
    String? userRole,
  }) {
    return EmployeesScreenState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
      selectedRoleFilter: selectedRoleFilter,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [
    employees, 
    isLoading, 
    searchQuery, 
    selectedIndex,
    selectedRoleFilter,
    userRole,
  ];
}
