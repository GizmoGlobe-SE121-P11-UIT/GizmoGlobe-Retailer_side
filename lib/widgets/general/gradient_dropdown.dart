import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class GradientDropdown<T> extends StatelessWidget {
  final List<T> Function(String filter, dynamic infiniteScrollProps) items;
  final bool Function(T? d1, T? d2) compareFn;
  final String Function(T d) itemAsString;
  final void Function(T? d) onChanged;
  final T? selectedItem;
  final String hintText;
  final double fontSize;

  const GradientDropdown({
    super.key,
    required this.items,
    required this.compareFn,
    required this.itemAsString,
    required this.onChanged,
    required this.selectedItem,
    this.hintText = '',
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderSide =
        BorderSide(color: colorScheme.outlineVariant, width: 1.2);
    final focusBorderSide = BorderSide(color: colorScheme.primary, width: 1.8);
    final fillColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return DropdownSearch<T>(
      items: items,
      compareFn: compareFn,
      itemAsString: itemAsString,
      dropdownBuilder: (context, selectedItem) => _customDropdownBuilder(
        context,
        selectedItem != null ? itemAsString(selectedItem) : '',
        textColor,
        fontSize,
      ),
      suffixProps: DropdownSuffixProps(
        dropdownButtonProps: DropdownButtonProps(
          iconClosed: const Icon(Icons.keyboard_arrow_down),
          iconOpened: const Icon(Icons.keyboard_arrow_up),
          color: colorScheme.primary,
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.primary,
              ),
            ),
            filled: false,
            hintText: 'Search',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontFamily: 'Montserrat',
            fontSize: fontSize,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: focusBorderSide,
          ),
          fillColor: fillColor,
          filled: true,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
      onChanged: onChanged,
      selectedItem: selectedItem,
    );
  }

  Widget _customDropdownBuilder(
      BuildContext context, String text, Color textColor, double fontSize) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Montserrat',
          fontSize: fontSize,
        ),
      ),
    );
  }
}
