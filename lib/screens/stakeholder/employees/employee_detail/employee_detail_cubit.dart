import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'employee_detail_state.dart';

class EmployeeDetailCubit extends Cubit<EmployeeDetailState> {
  final Firebase _firebase = Firebase();

  EmployeeDetailCubit(Employee employee) 
      : super(EmployeeDetailState(employee: employee)) {
    _loadUserRole();
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

  Future<void> updateEmployee(Employee updatedEmployee) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.updateEmployee(updatedEmployee);
      emit(state.copyWith(
        employee: updatedEmployee,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> deleteEmployee() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.deleteEmployee(state.employee.employeeID!);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
} 