import 'package:flutter/material.dart';

class DefaultIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final double size;

  const DefaultIcon({
    super.key,
    required this.icon,
    required this.isSelected,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onPrimary,
    );
  }
}
