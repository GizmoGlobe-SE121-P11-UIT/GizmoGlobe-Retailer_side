import 'package:flutter/material.dart';

class SelectableGradientIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final double size;
  final String? label;

  const SelectableGradientIcon({
    super.key,
    required this.icon,
    required this.isSelected,
    this.size = 24.0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: size,
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          fill: isSelected ? 1 : 0,
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label!,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }
}
