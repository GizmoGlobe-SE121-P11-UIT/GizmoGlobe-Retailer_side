enum CategoryEnum {
  empty(''),
  ram('RAM'),
  cpu('CPU'),
  psu('PSU'),
  gpu('GPU'),
  drive('Drive'),
  mainboard('Mainboard');

  final String description;

  const CategoryEnum(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }

  static List<CategoryEnum> get nonEmptyValues {
    return CategoryEnum.values.where((e) => e != CategoryEnum.empty).toList();
  }
}

extension CategoryEnumExtension on CategoryEnum {
  static CategoryEnum fromName(String name) {
    return CategoryEnum.nonEmptyValues.firstWhere((e) => e.getName() == name);
  }
}