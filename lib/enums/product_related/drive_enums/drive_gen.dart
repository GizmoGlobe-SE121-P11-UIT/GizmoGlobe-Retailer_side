enum DriveGen {
  unknown('Unknown', 'Unknown'),
  gen3('Gen 3', 'III'),
  gen4('Gen 4', 'IV'),
  gen5('Gen 5', 'V');

  final String description;
  final String romanNumeral;

  const DriveGen(this.description, this.romanNumeral);

  String getName() {
    return name;
  }

  static List<DriveGen> getValues() {
    return DriveGen.values.where((e) => e != DriveGen.unknown).toList();
  }

  @override
  String toString() {
    return description;
  }

  String toRoman() {
    return romanNumeral;
  }
}

extension DriveGenExtension on DriveGen {
  static DriveGen fromName(String name) {
    return DriveGen.values.firstWhere(
        (e) => e.getName() == name,
        orElse: () => DriveGen.unknown
    );
  }
}
