class VendorPermissions {
  static bool canManageVendors(String? userRole) {
    return userRole == 'admin';
  }
} 