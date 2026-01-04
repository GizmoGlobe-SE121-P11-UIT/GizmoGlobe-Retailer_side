import 'dart:async';
import 'package:gizmoglobe_client/screens/stakeholder/permissions/stakeholder_permissions.dart';
import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/stakeholder/customers/customers_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/employees/employees_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_state.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendors_screen_view.dart';
import 'package:gizmoglobe_client/components/general/web_header.dart';
import 'package:gizmoglobe_client/components/general/web_sidebar.dart';

class StakeholderScreen extends StatefulWidget {
  final bool showFullLayout;

  const StakeholderScreen({super.key, this.showFullLayout = false});

  static Widget newInstance() => BlocProvider(
        create: (context) => StakeholderScreenCubit(),
        child: const StakeholderScreen(showFullLayout: false),
      );

  static Widget newInstanceWithTab({int? initialTabIndex}) => BlocProvider(
        create: (context) =>
            StakeholderScreenCubit(initialTabIndex: initialTabIndex),
        child:
            StakeholderScreenWithInitialTab(initialTabIndex: initialTabIndex),
      );

  @override
  State<StakeholderScreen> createState() => _StakeholderScreenState();
}

// dart
class _StakeholderScreenState extends State<StakeholderScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<dynamic>? _hashChangeSubscription;
  late TabController _tabController;

  // Mobile sidebar state
  bool isSidebarCompact = false;
  bool isMobileSidebarVisible = false;

  // Mobile breakpoint threshold - collapse sidebar on narrower screens
  static const double mobileBreakpoint = 900.0;
  // Compact breakpoint - auto-compact sidebar on medium screens
  static const double compactBreakpoint = 1100.0;

  /// Maps the visible tab index -> cubit logical index (0: customers, 1: employees, 2: vendors)
  late List<int> _displayedToCubitIndex;

  /// Reverse map: cubit logical index -> visible tab index
  late Map<int, int> _cubitToDisplayedIndex;

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
  void initState() {
    super.initState();

    final showEmployees = StakeholderPermissions.canViewEmployees();

    _displayedToCubitIndex = showEmployees ? [0, 1, 2] : [0, 2];
    _cubitToDisplayedIndex = {
      for (int i = 0; i < _displayedToCubitIndex.length; i++)
        _displayedToCubitIndex[i]: i
    };

    _tabController =
        TabController(length: _displayedToCubitIndex.length, vsync: this);

    // Sync TabController with cubit state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<StakeholderScreenCubit>();
        final displayed =
            _cubitToDisplayedIndex[cubit.state.selectedTabIndex] ?? 0;
        if (_tabController.index != displayed) {
          _tabController.animateTo(displayed, duration: Duration.zero);
        }
      }
    });

    // Listen to URL changes on web for hash routing
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
        if (mounted) {
          _handleHashChange();
        }
      });
    }
  }

  @override
  void dispose() {
    _hashChangeSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _handleHashChange() {
    if (kIsWeb) {
      final cubit = context.read<StakeholderScreenCubit>();
      if (cubit.state.isChangingTab) return;

      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      if (hash.startsWith('/stakeholders/')) {
        final pathSegments = hash.split('/');
        if (pathSegments.length >= 3) {
          final tabName = pathSegments[2].toLowerCase();
          int tabIndex;
          switch (tabName) {
            case 'customers':
              tabIndex = 0;
              break;
            case 'employees':
              tabIndex = 1;
              break;
            case 'vendors':
              tabIndex = 2;
              break;
            default:
              tabIndex = 0;
          }

          if (cubit.state.selectedTabIndex != tabIndex) {
            cubit.changeTab(tabIndex);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StakeholderScreenCubit, StakeholderScreenState>(
      listener: (context, state) {
        final displayed = _cubitToDisplayedIndex[state.selectedTabIndex] ?? 0;
        if (_tabController.index != displayed) {
          _tabController.animateTo(displayed, duration: Duration.zero);
        }
      },
      child: BlocBuilder<StakeholderScreenCubit, StakeholderScreenState>(
        builder: (context, state) {
          // Build visible tabs and children according to the mapping
          final tabs = _displayedToCubitIndex.map((cubitIndex) {
            switch (cubitIndex) {
              case 0:
                return Tab(text: S.of(context).customers);
              case 1:
                return Tab(text: S.of(context).employees);
              case 2:
              default:
                return Tab(text: S.of(context).vendors);
            }
          }).toList();

          final children = _displayedToCubitIndex.map((cubitIndex) {
            switch (cubitIndex) {
              case 0:
                return CustomersScreen.newInstance();
              case 1:
                return EmployeesScreen.newInstance();
              case 2:
              default:
                return VendorsScreen.newInstance();
            }
          }).toList();

          final content = GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: TabBar(
                  controller: _tabController,
                  onTap: (displayedIndex) async {
                    _tabController.animateTo(displayedIndex,
                        duration: Duration.zero);

                    final actualCubitIndex =
                        _displayedToCubitIndex[displayedIndex];
                    await context
                        .read<StakeholderScreenCubit>()
                        .changeTab(actualCubitIndex);

                    if (kIsWeb) {
                      String tabName;
                      switch (actualCubitIndex) {
                        case 0:
                          tabName = 'customers';
                          break;
                        case 1:
                          tabName = 'employees';
                          break;
                        case 2:
                        default:
                          tabName = 'vendors';
                      }
                      PlatformSpecificUtils.replaceState(
                          '/#/stakeholders/$tabName');
                    }
                  },
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  dividerColor: Colors.transparent,
                  tabs: tabs,
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    IndexedStack(
                      index:
                          _cubitToDisplayedIndex[state.selectedTabIndex] ?? 0,
                      children: children,
                    ),
                    if (state.isChangingTab)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: Center(
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );

          if (kIsWeb && widget.showFullLayout) {
            final isMobile = _isMobileMode(context);
            final screenWidth = MediaQuery.of(context).size.width;
            final shouldAutoCompact =
                screenWidth < compactBreakpoint && !isMobile;
            final colorScheme = Theme.of(context).colorScheme;
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
                  WebHeader(
                    unreadChats: 0,
                    isSidebarCompact: isSidebarCompact,
                    isMobileMode: isMobile,
                    onMenuPressed: _toggleMobileSidebar,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Main content area
                        Row(
                          children: [
                            // Desktop sidebar (hidden on mobile)
                            if (!isMobile) ...[
                              WebSidebarModes(
                                currentIndex: 3,
                                initialCompactMode: shouldAutoCompact,
                                onItemSelected: (value) {
                                  _closeMobileSidebar();
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
                            Expanded(child: content),
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
                                currentIndex: 3,
                                hideCollapseButton: true,
                                onItemSelected: (value) {
                                  _closeMobileSidebar();
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

          return content;
        },
      ),
    );
  }
}

// Widget to handle initial tab index for web navigation
class StakeholderScreenWithInitialTab extends StatefulWidget {
  final int? initialTabIndex;

  const StakeholderScreenWithInitialTab({super.key, this.initialTabIndex});

  @override
  State<StakeholderScreenWithInitialTab> createState() =>
      _StakeholderScreenWithInitialTabState();
}

class _StakeholderScreenWithInitialTabState
    extends State<StakeholderScreenWithInitialTab> {
  @override
  void initState() {
    super.initState();
    // Set the initial tab if provided - only for web
    if (kIsWeb && widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final cubit = context.read<StakeholderScreenCubit>();
          // Don't update if already changing tabs
          if (!cubit.state.isChangingTab &&
              cubit.state.selectedTabIndex != widget.initialTabIndex) {
            cubit.changeTab(widget.initialTabIndex!);
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(StakeholderScreenWithInitialTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab when initialTabIndex changes (e.g., from URL change)
    // Only update if not already changing tabs to prevent loops
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final cubit = context.read<StakeholderScreenCubit>();
          // Don't update if already changing tabs
          if (!cubit.state.isChangingTab &&
              cubit.state.selectedTabIndex != widget.initialTabIndex) {
            cubit.changeTab(widget.initialTabIndex!);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const StakeholderScreen(showFullLayout: true);
  }
}
