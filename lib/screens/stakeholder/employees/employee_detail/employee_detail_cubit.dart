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
      if (!isClosed) {
        emit(state.copyWith(userRole: userRole));
      }
    } catch (e) {
      // Error loading user role
    }
  }

  Future<void> updateEmployee(Employee updatedEmployee) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.updateEmployee(updatedEmployee);
      if (!isClosed) {
        emit(state.copyWith(
          employee: updatedEmployee,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  Future<void> deleteEmployee() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.deleteEmployee(state.employee.employeeID!);
      if (!isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }
}
