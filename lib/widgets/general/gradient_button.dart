import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPress;
  final Gradient? gradient;
  final double height;
  final double width;
  final double borderRadius;
  final String text;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  final bool isEnabled;

  const GradientButton({
    super.key,
    required this.onPress,
    this.gradient,
    this.height = 48.0,
    this.width = double.infinity,
    this.borderRadius = 10.0,
    this.text = '',
    this.fontSize = 16.0,
    this.fontColor = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                gradient != null ? null : Theme.of(context).colorScheme.primary,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: TextButton(
            onPressed: isEnabled ? onPress : null,
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
