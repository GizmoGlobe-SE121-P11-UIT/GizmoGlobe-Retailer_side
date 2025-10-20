enum InterfaceType {
  sata('SATA'),
  pcie('PCIe');

  final String description;

  const InterfaceType(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension InterfaceTypeExtension on InterfaceType {
  static InterfaceType fromName(String name) {
    return InterfaceType.values.firstWhere((e) => e.getName() == name);
  }
}
