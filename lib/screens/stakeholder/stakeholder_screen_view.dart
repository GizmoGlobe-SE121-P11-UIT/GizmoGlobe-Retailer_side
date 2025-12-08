import 'dart:async';
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

class _StakeholderScreenState extends State<StakeholderScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<dynamic>? _hashChangeSubscription;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Sync TabController with cubit state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<StakeholderScreenCubit>();
        if (_tabController.index != cubit.state.selectedTabIndex) {
          _tabController.animateTo(cubit.state.selectedTabIndex,
              duration: Duration.zero);
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
      // Don't react to hash changes if we're already changing tabs (prevents loop)
      if (cubit.state.isChangingTab) {
        return;
      }

      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      // Parse hash like /#/stakeholders/customers, /#/stakeholders/employees, /#/stakeholders/vendors
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
              tabIndex = 0; // Default to customers
          }

          // Update tab if it's different from current
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
        // Sync TabController with state
        if (_tabController.index != state.selectedTabIndex) {
          _tabController.animateTo(state.selectedTabIndex,
              duration: Duration.zero);
        }
      },
      child: BlocBuilder<StakeholderScreenCubit, StakeholderScreenState>(
        builder: (context, state) {
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
                  onTap: (index) async {
                    // Animate tab immediately without transition
                    _tabController.animateTo(index, duration: Duration.zero);
                    await context
                        .read<StakeholderScreenCubit>()
                        .changeTab(index);

                    // Update URL for web navigation using hash routing
                    // Do this after loading completes to prevent hash change loop
                    if (kIsWeb) {
                      String tabName;
                      switch (index) {
                        case 0:
                          tabName = 'customers';
                          break;
                        case 1:
                          tabName = 'employees';
                          break;
                        case 2:
                          tabName = 'vendors';
                          break;
                        default:
                          tabName = 'customers';
                      }
                      // Use replaceState to avoid adding to history during loading
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
                  tabs: [
                    Tab(text: S.of(context).customers),
                    Tab(text: S.of(context).employees),
                    Tab(text: S.of(context).vendors),
                  ],
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: state.selectedTabIndex,
                      children: [
                        CustomersScreen.newInstance(),
                        EmployeesScreen.newInstance(),
                        VendorsScreen.newInstance(),
                      ],
                    ),
                    // Show loading indicator overlay during tab change
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

          // Use web layout for web platform - only show full layout when accessed directly
          if (kIsWeb && widget.showFullLayout) {
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
                  const WebHeader(
                    unreadChats: 0,
                    isSidebarCompact: false,
                  ),
                  // Main content with sidebar
                  Expanded(
                    child: Row(
                      children: [
                        WebSidebarModes(
                          currentIndex: 3, // Stakeholder index
                          onItemSelected: (value) {
                            // Navigation is handled inside WebSidebarModes to avoid duplicates
                          },
                          items: items,
                          onCompactModeChanged: (isCompact) {
                            // Handle sidebar compact mode if needed
                          },
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: content),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Use regular layout for mobile
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
