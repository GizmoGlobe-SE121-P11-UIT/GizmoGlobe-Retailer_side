enum RoleEnum {
  owner('Owner'), // Chủ sở hữu
  manager('Manager'), // Quản lý
  employee('Employee'); // Nhân viên

  final String description;

  const RoleEnum(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension CategoryEnumExtension on RoleEnum {
  static RoleEnum fromName(String name) {
    return RoleEnum.values.firstWhere((e) => e.getName() == name);
  }
}