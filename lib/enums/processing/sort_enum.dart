enum SortEnum {
  releaseLatest('Release date: Latest'), // Ngày phát hành: Mới nhất
  releaseOldest('Release date: Oldest'), // Ngày phát hành: Cũ nhất
  stockHighest('Stock: Highest'), // Hàng tồn kho: Cao nhất
  stockLowest('Stock: Lowest'), //  Hàng tồn kho: Thấp nhất
  salesHighest('Sale: Highest'), // Số lượng bán: Cao nhất
  salesLowest('Sale: Lowest'); // Số lượng bán: Thấp nhất

  final String description;
  const SortEnum(this.description);

  @override
  String toString() {
    return description;
  }
}