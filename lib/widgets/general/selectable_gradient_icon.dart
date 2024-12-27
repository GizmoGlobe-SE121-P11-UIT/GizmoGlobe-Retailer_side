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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isSelected
            ? ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: size,
                  color: Colors.white,
                ),
              )
            : Icon(
                icon,
                size: size,
                color: Colors.white,
                fill: 0,
              ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ),
      ],
    );
  }
}