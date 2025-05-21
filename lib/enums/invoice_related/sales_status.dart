enum SalesStatus {
  pending('Pending'), //Đang chờ
  preparing('Preparing'), //Đang chuẩn bị
  shipping('Shipping'), //Đang giao hàng
  shipped('Shipped'), //Đã giao hàng
  completed('Completed'), //Đã hoàn thành
  cancelled('Cancelled'); //Đã hủy

  final String description;

  const SalesStatus(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension SalesStatusExtension on SalesStatus {
  static SalesStatus fromName(String name) {
    return SalesStatus.values.firstWhere((e) => e.getName() == name);
  }
}