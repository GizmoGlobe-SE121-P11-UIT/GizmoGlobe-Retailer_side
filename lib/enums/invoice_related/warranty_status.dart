enum WarrantyStatus {
  pending("Pending"), //Đang chờ
  processing("Processing"), //Đang xử lý
  completed("Completed"), //Đã hoàn thành
  denied("Denied"); //Từ chối

  final String description;

  const WarrantyStatus(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension WarrantyStatusExtension on WarrantyStatus {
  static WarrantyStatus fromName(String name) {
    return WarrantyStatus.values.firstWhere((e) => e.getName() == name);
  }
}