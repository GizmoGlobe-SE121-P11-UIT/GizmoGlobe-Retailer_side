import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/user/user_screen/user_screen_view.dart';

class WebSidebarModes extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onItemSelected;
  final List<SidebarItem> items;
  final void Function(bool)? onCompactModeChanged;
  final bool initialCompactMode;
  final bool hideCollapseButton;

  const WebSidebarModes({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.onCompactModeChanged,
    this.initialCompactMode = false,
    this.hideCollapseButton = false,
  });

  @override
  State<WebSidebarModes> createState() => _WebSidebarModesState();
}

class _WebSidebarModesState extends State<WebSidebarModes> {
  late bool isCompactMode;

  @override
  void initState() {
    super.initState();
    isCompactMode = widget.initialCompactMode;
  }

  @override
  void didUpdateWidget(WebSidebarModes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync compact mode when initialCompactMode prop changes
    if (oldWidget.initialCompactMode != widget.initialCompactMode) {
      setState(() {
        isCompactMode = widget.initialCompactMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int profileIndex = widget.items.length - 1;
    final List<SidebarItem> mainItems = widget.items.sublist(0, profileIndex);

    final int selectedForRail = widget.currentIndex < mainItems.length
        ? widget.currentIndex
        : (mainItems.isNotEmpty ? 0 : 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCompactMode ? 80 : 200,
      color: colorScheme.surface.withValues(alpha: 0.7),
      child: Column(
        children: [
          if (!widget.hideCollapseButton)
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
                  widget.onCompactModeChanged?.call(isCompactMode);
                },
                tooltip: isCompactMode ? 'Expand' : 'Collapse',
              ),
            ),
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
                  onTap: () {
                    String target = '/main';
                    switch (index) {
                      case 0:
                        target = '/main';
                        break;
                      case 1:
                        target = '/product';
                        break;
                      case 2:
                        target = '/invoices';
                        break;
                      case 3:
                        target = '/stakeholders';
                        break;
                      case 4:
                        target = '/vouchers';
                        break;
                    }
                    // Only navigate if different to reduce redundant pushes
                    final current = ModalRoute.of(context)?.settings.name;
                    if (current != target) {
                      // Call the callback first, before navigation
                      // This prevents setState after dispose race condition
                      widget.onItemSelected(index);
                      Navigator.pushReplacementNamed(context, target);
                    } else {
                      // Still call the callback if we're already on the route
                      widget.onItemSelected(index);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _UserProfileSection(
              key: const ValueKey('user_profile_section'),
              selected: widget.currentIndex == profileIndex,
              isCompact: isCompactMode,
              onTap: () {
                // Show user screen modal for web
                UserScreen.showModal(context);
              },
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

class _UserProfileSection extends StatefulWidget {
  final bool selected;
  final bool isCompact;
  final VoidCallback onTap;

  const _UserProfileSection({
    super.key,
    required this.selected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_UserProfileSection> createState() => _UserProfileSectionState();
}

// Static cache that persists across widget recreations
class _UserProfileCache {
  static DocumentSnapshot? _cachedSnapshot;
  static bool _isInitialized = false;
  static final _stateController = StreamController<void>.broadcast();

  static Stream<void> get stateStream => _stateController.stream;

  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Fetch initial user data
    _fetchUserData();

    // Listen to auth state changes to handle initial load and re-auth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserData();
      } else {
        _cachedSnapshot = null;
        _stateController.add(null);
      }
    });
  }

  static Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _cachedSnapshot = userDoc;
          _stateController.add(null);
        } else {
          _cachedSnapshot = null;
          _stateController.add(null);
        }
      } else {
        _cachedSnapshot = null;
        _stateController.add(null);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data in sidebar: $e');
      }
      _cachedSnapshot = null;
      _stateController.add(null);
    }
  }

  static DocumentSnapshot? get snapshot => _cachedSnapshot;
}

class _UserProfileSectionState extends State<_UserProfileSection> {
  StreamSubscription<void>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize static cache if not already done
    _UserProfileCache.initialize();
    // Listen for cache state changes to trigger rebuild
    _stateSubscription = _UserProfileCache.stateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_UserProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild if the compact mode actually changed
    if (oldWidget.isCompact != widget.isCompact ||
        oldWidget.selected != widget.selected) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bg = widget.selected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;
    final Color fg =
        widget.selected ? colorScheme.primary : colorScheme.onSurface;

    // Always render from static cached data - never show loading once we have data
    final cachedSnapshot = _UserProfileCache.snapshot;
    if (cachedSnapshot != null && cachedSnapshot.exists) {
      final userData = cachedSnapshot.data() as Map<String, dynamic>;
      final username = userData['username'] ?? 'User';
      final email =
          userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: widget.isCompact
                ? _buildCompactProfile(context, username, bg, fg)
                : _buildFullProfile(context, username, email, bg, fg),
          ),
        ),
      );
    }

    // Show loading only on initial load when we truly have no data
    return _buildLoadingProfile(context, bg, fg);
  }

  Widget _buildLoadingProfile(BuildContext context, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: widget.isCompact
          ? Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(8),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildCompactProfile(
      BuildContext context, String username, Color bg, Color fg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: fg.withValues(alpha: 0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFullProfile(
      BuildContext context, String username, String email, Color bg, Color fg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: fg.withValues(alpha: 0.1),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: fg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                username,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
