enum SortEnum {
  releaseLatest('Release date: Latest'),
  releaseOldest('Release date: Oldest'),
  stockHighest('Stock: Highest'),
  stockLowest('Stock: Lowest'),
  salesHighest('Sale: Highest'),
  salesLowest('Sale: Lowest');

  final String description;
  const SortEnum(this.description);

  @override
  String toString() {
    return description;
  }
}