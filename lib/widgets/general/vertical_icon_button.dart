import 'package:flutter/material.dart';

class VerticalIconButton extends StatelessWidget {
  final VoidCallback onPress;
  final IconData icon;
  final String text;
  final double iconSize;
  final double fontSize;
  final bool isSelected;

  const VerticalIconButton({
    super.key,
    required this.onPress,
    required this.icon,
    required this.text,
    this.iconSize = 32.0,
    this.fontSize = 16.0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onPress,
      child: Column(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
