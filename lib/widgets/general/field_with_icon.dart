import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldWithIcon extends StatelessWidget {
  final double height;
  final bool readOnly;
  final String hintText;
  final Color? fillColor;
  final VoidCallback? onTap;
  final Icon? prefixIcon;
  final VoidCallback? onPrefixIconPressed;
  final Icon? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double fontSize;
  final FontWeight fontWeight;
  final BorderRadius borderRadius;
  final bool obscureText;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final TextEditingController controller;
  final Color? hintTextColor;
  final Color? textColor;
  final FocusNode? focusNode;

  const FieldWithIcon({
    super.key,
    this.height = 45,
    this.readOnly = false,
    this.hintText = '',
    this.fillColor,
    this.onTap,
    this.prefixIcon,
    this.onPrefixIconPressed,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType,
    this.inputFormatters,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.obscureText = false,
    this.onSubmitted,
    this.onChanged,
    required this.controller,
    this.hintTextColor,
    this.textColor,
    this.focusNode,
  });

  String? getText() {
    return controller.text;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveFillColor = fillColor ?? colorScheme.surface;
    final effectiveTextColor = textColor ?? colorScheme.onSurface;
    final effectiveHintTextColor =
        hintTextColor ?? colorScheme.onSurfaceVariant;
    final borderSide =
        BorderSide(color: colorScheme.outlineVariant, width: 1.2);
    final focusBorderSide = BorderSide(color: colorScheme.primary, width: 1.8);

    return SizedBox(
      height: height,
      child: TextFormField(
        readOnly: readOnly,
        textAlignVertical: TextAlignVertical.center,
        onTap: onTap,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        controller: controller,
        textInputAction: TextInputAction.done,
        focusNode: focusNode,
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: effectiveFillColor,
          hintText: hintText,
          hintStyle: TextStyle(
            color: effectiveHintTextColor,
            fontFamily: 'Montserrat',
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          prefixIcon: prefixIcon != null
              ? InkWell(
                  onTap: onPrefixIconPressed,
                  child: prefixIcon,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? InkWell(
                  onTap: onSuffixIconPressed,
                  child: suffixIcon,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: focusBorderSide,
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: (height - fontSize) / 2 - 6, horizontal: 16),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters ??
            [FilteringTextInputFormatter.allow(RegExp(r'.*'))],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: effectiveTextColor,
          fontFamily: 'Montserrat',
        ),
        obscureText: obscureText,
      ),
    );
  }
}
