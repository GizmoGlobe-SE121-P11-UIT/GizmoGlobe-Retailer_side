enum InterfaceType {
  unknown('Unknown'),
  sata('SATA'),
  pcie('PCIe');

  final String description;

  const InterfaceType(this.description);

  String getName() {
    return name;
  }

  static List<InterfaceType> getValues() {
    return InterfaceType.values
        .where((e) => e != InterfaceType.unknown)
        .toList();
  }

  @override
  String toString() {
    return description;
  }
}

extension InterfaceTypeExtension on InterfaceType {
  static InterfaceType fromName(String name) {
    // Normalize the input name
    final normalized = name.toLowerCase().trim();

    // Handle variations and aliases
    switch (normalized) {
      case 'sata':
        return InterfaceType.sata;
      case 'nvme':
      case 'pcie':
      case 'pci-e':
      case 'pci express':
        return InterfaceType.pcie;
      default:
        // Try exact match with enum name
        return InterfaceType.values.firstWhere(
          (e) => e.getName().toLowerCase() == normalized,
          orElse: () => InterfaceType.unknown,
        );
    }
  }
}
