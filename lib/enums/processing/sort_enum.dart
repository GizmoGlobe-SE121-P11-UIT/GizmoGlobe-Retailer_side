import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

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

extension SortEnumLocalized on SortEnum {
  String localized(BuildContext context) {
    switch (this) {
      case SortEnum.releaseLatest:
        return S.of(context).releaseLatest;
      case SortEnum.releaseOldest:
        return S.of(context).releaseOldest;
      case SortEnum.stockHighest:
        return S.of(context).stockHighest;
      case SortEnum.stockLowest:
        return S.of(context).stockLowest;
      case SortEnum.salesHighest:
        return S.of(context).salesHighest;
      case SortEnum.salesLowest:
        return S.of(context).salesLowest;
    }
  }
}
