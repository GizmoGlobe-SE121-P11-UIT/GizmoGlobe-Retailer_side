import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../widgets/general/app_text_style.dart';
import '../../functions/converter.dart';

abstract class EndTimeInterface {
  DateTime get endTime;
  set endTime(DateTime endTime);

  // Widget detailsWidget(BuildContext context) {
  //   return Text(
  //     'Expires ${Converter.getTimeLeftString(endTime)}',
  //     style: AppTextStyle.regularText,
  //   );
  // }
}