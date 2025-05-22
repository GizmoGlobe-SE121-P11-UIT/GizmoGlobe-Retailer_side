import 'package:flutter/cupertino.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';

abstract class LimitedInterface {
  int get maximumUsage;
  int get usageLeft;

  set maximumUsage(int value);
  set usageLeft(int value);

  // Widget detailsWidget(BuildContext context) {
  //   return Text(
  //     'Usage left: $usageLeft/$maximumUsage',
  //     style: AppTextStyle.regularText,
  //   );
  // }
}