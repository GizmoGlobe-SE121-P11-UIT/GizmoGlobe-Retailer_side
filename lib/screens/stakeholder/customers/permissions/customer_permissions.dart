class CustomerPermissions {
  static bool canViewCustomers(String? userRole) {
    return userRole != null;  // All authenticated users can view
  }

  static bool canAddCustomers(String? userRole) {
    return userRole == 'admin' || userRole == 'manager';
  }

  static bool canEditCustomers(String? userRole) {
    return userRole == 'admin';
  }
} 