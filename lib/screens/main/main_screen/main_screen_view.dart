// lib/screens/main/main_screen/main_screen_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_view.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_in_screen/sign_in_view.dart';

import '../../../widgets/general/selectable_gradient_icon.dart';
import '../../../components/general/web_sidebar.dart';
import '../../../components/general/web_header.dart';
import '../../home/home_screen/home_screen_view.dart';
import '../../user/user_screen/user_screen_view.dart';

class MainScreen extends StatefulWidget {
  final int? initialIndex;

  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  bool isSidebarCompact = false;
  bool isMobileSidebarVisible = false;
  MainScreenCubit get cubit => context.read<MainScreenCubit>();

  // Mobile breakpoint threshold - collapse sidebar on narrower screens
  static const double mobileBreakpoint = 900.0;
  // Compact breakpoint - auto-compact sidebar on medium screens
  static const double compactBreakpoint = 1100.0;

  final List<Widget Function()> widgetList = [
    () => HomeScreen.newInstance(),
    () => ProductScreen.newInstance(),
    () => InvoiceScreen.newInstance(), // This will use showFullLayout: false
    () => StakeholderScreen.newInstance(),
    () => VoucherScreen.newInstance(),
    () => kIsWeb ? const SizedBox.shrink() : UserScreen.newInstance(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial index if provided
    if (widget.initialIndex != null) {
      index = widget.initialIndex!;
    }
    cubit.getUserName();
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update index if initialIndex actually changed
    if (oldWidget.initialIndex != widget.initialIndex) {
      final newIndex = widget.initialIndex ?? 0;
      if (index != newIndex) {
        setState(() {
          index = newIndex;
        });
      }
    }
  }

  bool _isMobileMode(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  void _toggleMobileSidebar() {
    setState(() {
      isMobileSidebarVisible = !isMobileSidebarVisible;
    });
  }

  void _closeMobileSidebar() {
    if (isMobileSidebarVisible) {
      setState(() {
        isMobileSidebarVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL SECURITY: Check authentication directly in MainScreen
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    // ABSOLUTE WEB SECURITY: Block access if not authenticated
    if (kIsWeb && !isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Additional security: Block access if user is null or has no UID
    if (user == null || user.uid.isEmpty) {
      return SignInScreen.newInstance();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Web: use left sidebar with header; Mobile: keep bottom navigation
    if (kIsWeb) {
      final isMobile = _isMobileMode(context);
      final screenWidth = MediaQuery.of(context).size.width;
      final shouldAutoCompact = screenWidth < compactBreakpoint && !isMobile;
      final items = buildDefaultSidebarItems(
        home: S.of(context).home,
        product: S.of(context).product,
        invoice: S.of(context).invoice,
        stakeholder: S.of(context).stakeholder,
        voucher: S.of(context).voucher,
        profile: S.of(context).profile,
      );

      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            // Web Header
            WebHeader(
              unreadChats: 0,
              isSidebarCompact: isSidebarCompact,
              isMobileMode: isMobile,
              onMenuPressed: _toggleMobileSidebar,
            ),
            // Main content with sidebar
            Expanded(
              child: Stack(
                children: [
                  // Main content area
                  Row(
                    children: [
                      // Desktop sidebar (hidden on mobile)
                      if (!isMobile) ...[
                        WebSidebarModes(
                          currentIndex: index,
                          initialCompactMode: shouldAutoCompact,
                          onItemSelected: (value) {
                            if (value != index) {
                              setState(() {
                                index = value;
                              });

                              // For web only: use Navigator for proper routing
                              if (kIsWeb) {
                                if (value == 2) {
                                  Navigator.pushReplacementNamed(
                                      context, '/invoices');
                                } else if (value == 3) {
                                  Navigator.pushReplacementNamed(
                                      context, '/stakeholders');
                                } else if (value == 4) {
                                  Navigator.pushReplacementNamed(
                                      context, '/vouchers');
                                }
                                // Profile section (value == 5) is handled directly in the sidebar
                              }
                            }
                          },
                          items: items,
                          onCompactModeChanged: (isCompact) {
                            setState(() {
                              isSidebarCompact = isCompact;
                            });
                          },
                        ),
                        const VerticalDivider(width: 1),
                      ],
                      Expanded(child: widgetList[index]()),
                    ],
                  ),
                  // Mobile sidebar overlay
                  if (isMobile && isMobileSidebarVisible) ...[
                    // Backdrop
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _closeMobileSidebar,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    // Sidebar drawer
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 280,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(4, 0),
                            ),
                          ],
                        ),
                        child: WebSidebarModes(
                          currentIndex: index,
                          hideCollapseButton: true,
                          onItemSelected: (value) {
                            _closeMobileSidebar();
                            if (value != index) {
                              setState(() {
                                index = value;
                              });

                              // For web only: use Navigator for proper routing
                              if (kIsWeb) {
                                if (value == 2) {
                                  Navigator.pushReplacementNamed(
                                      context, '/invoices');
                                } else if (value == 3) {
                                  Navigator.pushReplacementNamed(
                                      context, '/stakeholders');
                                } else if (value == 4) {
                                  Navigator.pushReplacementNamed(
                                      context, '/vouchers');
                                }
                              }
                            }
                          },
                          items: items,
                          initialCompactMode: false,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widgetList[index](),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            if (value != index) {
              setState(() {
                index = value;
              });
            }
          },
          currentIndex: index,
          backgroundColor: colorScheme.primary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 3,
          items: [
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.home,
                isSelected: index == 0,
                label: S.of(context).home, // Trang chủ
              ),
              label: S.of(context).home, // Trang chủ
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.inventory,
                isSelected: index == 1,
                label: S.of(context).product, // Sản phẩm
              ),
              label: S.of(context).product, // Sản phẩm
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.receipt,
                isSelected: index == 2,
                label: S.of(context).invoice, // Hóa đơn
              ),
              label: S.of(context).invoice, // Hóa đơn
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.groups,
                isSelected: index == 3,
                label: S.of(context).stakeholder,
              ),
              label: S.of(context).stakeholder,
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.discount,
                isSelected: index == 4,
                label: S.of(context).voucher,
              ),
              label: S.of(context).voucher,
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.account_circle,
                isSelected: index == 5,
                label: S.of(context).profile,
              ),
              label: S.of(context).profile,
            ),
          ],
        ),
      ),
    );
  }
}
