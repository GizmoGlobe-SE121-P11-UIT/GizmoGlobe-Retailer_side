enum DriveType {
  unknown('Unknown'),
  hdd('HDD'),
  sataSSD('SATA SSD'),
  m2NGFF('M2 NGFF'),
  m2NVME('M2 NVME');

  final String description;

  const DriveType(this.description);

  String getName() {
    return name;
  }

  static List<DriveType> getValues() {
    return DriveType.values.where((e) => e != DriveType.unknown).toList();
  }

  @override
  String toString() {
    return description;
  }

  factory DriveType.fromJson(Map<String, dynamic> json) {
    String name = json['driveType'] ?? 'Unknown';
    return DriveTypeExtension.fromName(name);
  }
}

extension DriveTypeExtension on DriveType {
  static DriveType fromName(String name) {
    // Normalize the input name
    final normalized = name.toLowerCase().trim();

    // Handle variations and aliases
    switch (normalized) {
      case 'hdd':
        return DriveType.hdd;
      case 'sata_ssd':
      case 'satassd':
      case 'sata ssd':
        return DriveType.sataSSD;
      case 'm2_ngff':
      case 'm2ngff':
      case 'm2 ngff':
      case 'm.2 ngff':
        return DriveType.m2NGFF;
      case 'ssd_nvme':
      case 'ssdnvme':
      case 'ssd nvme':
      case 'nvme':
      case 'm2_nvme':
      case 'm2nvme':
      case 'm2 nvme':
      case 'm.2 nvme':
        return DriveType.m2NVME;
      default:
        // Try exact match with enum name
        return DriveType.values.firstWhere(
            (e) => e.getName().toLowerCase() == normalized,
            orElse: () => DriveType.unknown);
    }
  }
}
