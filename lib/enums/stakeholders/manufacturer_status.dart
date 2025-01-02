enum ManufacturerStatus {
  active,
  inactive;

  String getName() {
    switch (this) {
      case ManufacturerStatus.active:
        return 'Active';
      case ManufacturerStatus.inactive:
        return 'Inactive';
    }
  }
} 