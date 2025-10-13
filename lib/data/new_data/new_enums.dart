enum Socket {
    lga1700('LGA 1700'),
    lga1200('LGA 1200'),
    lga1151('LGA 1151'),
    lga1150('LGA 1150'),
    am4('AM4'),
    am5('AM5'),
    tr4('TR4'),
    sTRX4('sTRX4'),
    sWRX8('sWRX8'),
    sp3('SP3'),
    sp5('SP5');

  final String description;

  const Socket(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension SocketExtension on Socket {
  static Socket fromName(String name) {
    return Socket.values.firstWhere((e) => e.getName() == name);
  }
}

enum DriveFormFactor {
    m2_2280('M.2 2280'),
    m2_2230('M.2 2230'),
    m2_2242('M.2 2242'),
    inch3_5('3.5"'),
    inch2_5('2.5"');
    
    final String description;
    
    const DriveFormFactor(this.description);
    
    String getName() {
        return name;
    }
    
    @override
    String toString() {
        return description;
    }
}

extension DriveFormFactorExtension on DriveFormFactor {
    static DriveFormFactor fromName(String name) {
        return DriveFormFactor.values.firstWhere((e) => e.getName() == name);
    }
}

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

enum GPUVersion {
    gddr4('GDDR4'),
    gddr5('GDDR5'),
    gddr5x('GDDR5X'),
    gddr6('GDDR6'),
    gddr6x('GDDR6X'),
    gddr7('GDDR7'),
    gddr7x('GDDR7X');

  final String description;

  const GPUVersion(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension GPUVersionExtension on GPUVersion {
  static GPUVersion fromName(String name) {
    return GPUVersion.values.firstWhere((e) => e.getName() == name);
  }
}

enum DriveGen {
    gen3('Gen 3', 'III'),
    gen4('Gen 4', 'IV'),
    gen5('Gen 5', 'V');

  final String description;
  final String romanNumeral;

  const DriveGen(this.description, this.romanNumeral);

  String getName() {
    return name;
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
    return DriveGen.values.firstWhere((e) => e.getName() == name);
  }
}
