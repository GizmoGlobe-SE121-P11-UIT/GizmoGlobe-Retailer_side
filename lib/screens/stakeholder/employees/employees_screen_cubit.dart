import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import '../../../objects/employee.dart';
import 'employees_screen_state.dart';

class EmployeesScreenCubit extends Cubit<EmployeesScreenState> {
  final _firebase = Firebase();
  late final Stream<List<Employee>> _employeesStream;
  StreamSubscription<List<Employee>>? _subscription;
  List<Employee> _allEmployees = [];

  EmployeesScreenCubit() : super(const EmployeesScreenState()) {
    _employeesStream = _firebase.employeesStream();
    _listenToEmployees();
    _loadUserRole();
    loadEmployees();
  }

  void _listenToEmployees() {
    _subscription = _employeesStream.listen((employees) {
      _allEmployees = employees;
      if (state.selectedRoleFilter != null) {
        filterByRole(state.selectedRoleFilter);
      } else if (state.searchQuery.isNotEmpty) {
        searchEmployees(state.searchQuery);
      } else {
        emit(state.copyWith(employees: employees));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadEmployees() async {
    emit(state.copyWith(isLoading: true));
    try {
      final employees = await _firebase.getEmployees();
      emit(state.copyWith(
        employees: employees,
        isLoading: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error when loading the employee list: $e');
      } // Lỗi khi tải danh sách nhân viên
      emit(state.copyWith(isLoading: false));
    }
  }

  void searchEmployees(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      loadEmployees();
      return;
    }

    final filteredEmployees = state.employees.where((employee) {
      return employee.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          employee.email.toLowerCase().contains(query.toLowerCase()) ||
          employee.phoneNumber.contains(query) ||
          employee.role.toString().contains(query);
    }).toList();

    emit(state.copyWith(employees: filteredEmployees));
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firebase.updateEmployee(employee);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      if (kDebugMode) {
        print('Error updating employee: $e');
      } // Lỗi khi cập nhật nhân viên
      // You might want to handle the error appropriately
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firebase.deleteEmployee(employeeId);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting employee: $e');
      } // Lỗi khi xóa nhân viên
      // You might want to handle the error appropriately
    }
  }

  Future<String?> createEmployee(
    String name, 
    String email, 
    String phone, 
    RoleEnum role,
  ) async {
    try {
      final employee = Employee(
        employeeID: null,
        employeeName: name.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
        role: role,
      );
      
      await _firebase.addEmployee(employee);
      return null; // Return null if successful
      
    } catch (e) {
      if (kDebugMode) {
        print('Error creating employee: $e');
      } // Lỗi khi tạo nhân viên
      return e.toString(); // Return error message
    }
  }

  void filterByRole(RoleEnum? role) {
    emit(state.copyWith(selectedRoleFilter: role));
    
    if (role == null) {
      emit(state.copyWith(employees: _allEmployees));
      return;
    }

    final filteredEmployees = _allEmployees.where((employee) {
      return employee.role == role;
    }).toList();

    emit(state.copyWith(employees: filteredEmployees));
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi khi tải vai trò người dùng
    }
  }
}