import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

class EmployeePermissions {
  static bool canViewEmployees(String? userRole) {
    return userRole != null;  // All authenticated users can view
  }

  static bool canAddEmployees(String? userRole) {
    return userRole == 'admin' || userRole == 'manager';  // Admin and manager can add
  }

  static bool canEditEmployee(String? userRole, Employee employee) {
    if (employee.role == RoleEnum.owner) {
      return false;  // Owner accounts are read-only for everyone
    }
    
    if (userRole == 'admin') {
      return true;  // Admin can edit all except owner accounts
    }
    
    if (userRole == 'manager') {
      return employee.role == RoleEnum.employee;  // Manager can only edit employees
    }
    
    return false;  // Employees can't edit anyone
  }

  static bool canEditEmployeeRole(String? userRole, Employee employee) {
    if (employee.role == RoleEnum.owner) {
      return false;  // Owner role can't be changed
    }
    
    return userRole == 'admin';  // Only admin can change roles
  }

  static bool canDeleteEmployee(String? userRole, Employee employee) {
    if (employee.role == RoleEnum.owner) {
      return false;  // Owner accounts can't be deleted
    }
    
    return userRole == 'admin';  // Only admin can delete non-owner accounts
  }

  static bool isReadOnly(String? userRole, Employee employee) {
    if (employee.role == RoleEnum.owner) {
      return true;  // Owner accounts are always read-only
    }
    
    if (userRole == 'admin') {
      return false;  // Admin has full access to non-owner accounts
    }
    
    if (userRole == 'manager') {
      return employee.role != RoleEnum.employee;  // Manager can only edit employees
    }
    
    return true;  // Everyone else is read-only
  }
} 