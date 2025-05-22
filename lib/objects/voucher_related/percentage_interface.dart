import 'package:flutter/cupertino.dart';

import '../../widgets/general/app_text_style.dart';

abstract class PercentageInterface {
  double get maximumDiscountValue;
  set maximumDiscountValue(double value);

  // Widget detailsWidget(BuildContext context) {
  //   return Text(
  //     'Maximum discount $maximumDiscountValue\$',
  //     style: AppTextStyle.regularText,
  //   );
  // }
}