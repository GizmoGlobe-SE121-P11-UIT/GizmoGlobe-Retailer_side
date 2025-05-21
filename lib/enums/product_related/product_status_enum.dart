enum ProductStatusEnum {
  active('Active'), // Đang hoạt động
  outOfStock('Out of Stock'), // Hết hàng
  discontinued('Discontinued'); // Ngừng kinh doanh

  final String description;

  const ProductStatusEnum(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension ProductStatusEnumExtension on ProductStatusEnum {
  static ProductStatusEnum fromName(String name) {
    return ProductStatusEnum.values.firstWhere((e) => e.getName() == name);
  }
}