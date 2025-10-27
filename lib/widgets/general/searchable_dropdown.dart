import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatelessWidget {
  final List<T> Function(String filter, dynamic infiniteScrollProps) items;
  final bool Function(T? d1, T? d2) compareFn;
  final String Function(T d) itemAsString;
  final void Function(T? d) onChanged;
  final T? selectedItem;
  final String hintText;
  final String labelText;
  final String searchHintText;
  final IconData? prefixIcon;
  final double fontSize;
  final bool enabled;
  final String? Function(T?)? validator;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.compareFn,
    required this.itemAsString,
    required this.onChanged,
    required this.selectedItem,
    this.hintText = '',
    this.labelText = '',
    this.searchHintText = 'Search...',
    this.prefixIcon,
    this.fontSize = 16,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderSide = BorderSide(
      color: colorScheme.onSurface.withValues(alpha: 0.5),
      width: 1.0,
    );
    final focusBorderSide = BorderSide(
      color: colorScheme.primary,
      width: 2.0,
    );
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
          iconClosed: Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          iconOpened: Icon(
            Icons.keyboard_arrow_up,
            color: colorScheme.primary,
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: focusBorderSide,
            ),
            filled: true,
            fillColor: fillColor,
            hintText: searchHintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.primary,
            ),
          ),
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
        emptyBuilder: (context, searchEntry) => _buildEmptyState(
          context,
          searchEntry.isNotEmpty
              ? 'No items found matching "$searchEntry"'
              : 'No items available',
        ),
        loadingBuilder: (context, searchEntry) => _buildLoadingState(context),
        menuProps: MenuProps(
          backgroundColor: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: labelText.isNotEmpty ? labelText : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: fontSize,
          ),
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: fontSize,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: focusBorderSide,
          ),
          fillColor: fillColor,
          filled: true,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: colorScheme.primary,
                )
              : null,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
      onChanged: onChanged,
      selectedItem: selectedItem,
      enabled: enabled,
      validator: validator,
    );
  }

  Widget _customDropdownBuilder(
    BuildContext context,
    String text,
    Color textColor,
    double fontSize,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
