import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/checkbox_button.dart';

class OptionFilter<T> extends StatelessWidget {
  final String name;
  final List<T> enumValues;
  final List<T> selectedValues;
  final void Function(T value) onToggleSelection;
  final double? availableWidth; // when provided, used to compute 2-col width
  final String Function(T value)? labelBuilder; // optional custom label builder

  const OptionFilter({
    super.key,
    required this.name,
    required this.enumValues,
    required this.selectedValues,
    required this.onToggleSelection,
    this.availableWidth,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount = enumValues.length;
    final double baseWidth =
        availableWidth ?? MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyle.bigText.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: List.generate(itemCount + (itemCount % 2), (index) {
            if (index < itemCount) {
              return SizedBox(
                width: (baseWidth - 48) / 2,
                child: CheckboxButton(
                  text: labelBuilder != null
                      ? labelBuilder!(enumValues[index])
                      : enumValues[index].toString(),
                  isSelected: selectedValues.contains(enumValues[index]),
                  onSelected: () {
                    onToggleSelection(enumValues[index]);
                  },
                ),
              );
            } else {
              return SizedBox(
                width: (baseWidth - 48) / 2,
              );
            }
          }),
        ),
      ],
    );
  }
}
