import 'package:flutter/material.dart';

class WebSidebarModes extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onItemSelected;
  final List<SidebarItem> items;

  const WebSidebarModes({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<WebSidebarModes> createState() => _WebSidebarModesState();
}

class _WebSidebarModesState extends State<WebSidebarModes> {
  bool isCompactMode = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int profileIndex = widget.items.length - 1;
    final List<SidebarItem> mainItems = widget.items.sublist(0, profileIndex);
    final SidebarItem profileItem = widget.items[profileIndex];

    final int selectedForRail = widget.currentIndex < mainItems.length
        ? widget.currentIndex
        : (mainItems.isNotEmpty ? 0 : 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCompactMode ? 80 : 200,
      color: colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                isCompactMode ? Icons.chevron_right : Icons.chevron_left,
              ),
              onPressed: () {
                setState(() {
                  isCompactMode = !isCompactMode;
                });
              },
              tooltip: isCompactMode ? 'Expand' : 'Collapse',
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: mainItems.length,
              itemBuilder: (context, index) {
                final item = mainItems[index];
                final isSelected = selectedForRail == index;

                return _SidebarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  isCompact: isCompactMode,
                  onTap: () => widget.onItemSelected(index),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ProfileRailButton(
              label: profileItem.label,
              icon: profileItem.icon,
              selected: widget.currentIndex == profileIndex,
              isCompact: isCompactMode,
              onTap: () => widget.onItemSelected(profileIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String label;

  const SidebarItem({required this.icon, required this.label});
}

List<SidebarItem> buildDefaultSidebarItems({
  required String home,
  required String product,
  required String invoice,
  required String stakeholder,
  required String voucher,
  required String profile,
}) {
  return [
    SidebarItem(icon: Icons.home, label: home),
    SidebarItem(icon: Icons.inventory, label: product),
    SidebarItem(icon: Icons.receipt, label: invoice),
    SidebarItem(icon: Icons.groups, label: stakeholder),
    SidebarItem(icon: Icons.discount, label: voucher),
    SidebarItem(icon: Icons.account_circle, label: profile),
  ];
}

class _ProfileRailButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isCompact;
  final VoidCallback onTap;

  const _ProfileRailButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bg = selected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;
    final Color fg = selected ? colorScheme.primary : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: isCompact
              ? Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: fg, size: 24),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Icon(icon, color: fg, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SidebarItemWidget extends StatelessWidget {
  final SidebarItem item;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bgColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;
    final Color fgColor =
        isSelected ? colorScheme.primary : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: isCompact
                ? Icon(item.icon, color: fgColor, size: 24)
                : Row(
                    children: [
                      Icon(item.icon, color: fgColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: fgColor,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
