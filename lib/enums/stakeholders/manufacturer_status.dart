enum ManufacturerStatus {
  active,
  inactive;

  String getName() {
    switch (this) {
      case ManufacturerStatus.active:
        return 'Active'; // Hoạt động
      case ManufacturerStatus.inactive:
        return 'Inactive'; // Không hoạt động
    }
  }
} 

extension ManufacturerStatusExtension on ManufacturerStatus {
  static ManufacturerStatus fromName(String? name) {
    if (name == null) return ManufacturerStatus.active;
    switch (name.toLowerCase()) {
      case 'active':
        return ManufacturerStatus.active;
      case 'inactive':
        return ManufacturerStatus.inactive;
      default:
        return ManufacturerStatus.active;
    }
  }
} 