import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';

class CheckboxButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onSelected;

  const CheckboxButton({
    super.key,
    required this.text,
    required this.isSelected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          border:
              isSelected ? null : Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          style: AppTextStyle.buttonTextBold.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
