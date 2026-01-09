import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_state.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_view.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/voucher/voucher_card.dart';
import 'package:gizmoglobe_client/components/general/web_header.dart';
import 'package:gizmoglobe_client/components/general/web_sidebar.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';

import '../../../../enums/processing/process_state_enum.dart';

class VoucherScreenWebView extends StatefulWidget {
  final int? initialTabIndex;

  const VoucherScreenWebView({super.key, this.initialTabIndex});

  static Widget newInstance({int? initialTabIndex}) => BlocProvider(
        create: (context) => VoucherScreenCubit(),
        child: VoucherScreenWebView(initialTabIndex: initialTabIndex),
      );

  static int get lastSelectedTabIndex =>
      _VoucherScreenWebViewState._lastSelectedTabIndex;

  @override
  State<VoucherScreenWebView> createState() => _VoucherScreenWebViewState();
}

class _VoucherScreenWebViewState extends State<VoucherScreenWebView>
    with SingleTickerProviderStateMixin {
  static int _lastSelectedTabIndex = 0;
  bool _isChangingTab = false;

  // Mobile sidebar state
  bool isSidebarCompact = false;
  bool isMobileSidebarVisible = false;

  // Mobile breakpoint threshold - collapse sidebar on narrower screens
  static const double mobileBreakpoint = 900.0;
  // Compact breakpoint - auto-compact sidebar on medium screens
  static const double compactBreakpoint = 1100.0;

  VoucherScreenCubit get cubit => context.read<VoucherScreenCubit>();
  late TabController _tabController;

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
    // Use initialTabIndex if provided, otherwise use last selected tab
    final initialIndex = widget.initialTabIndex ?? _lastSelectedTabIndex;
    _tabController =
        TabController(length: 4, vsync: this, initialIndex: initialIndex);

    // Initialize cubit immediately
    cubit.initialize();

    // Set the initial tab if provided (or use preserved index)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
        _tabController.animateTo(initialIndex, duration: Duration.zero);
      }
    });

    // Listen to tab changes to preserve the selected tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _lastSelectedTabIndex = _tabController.index;
      }
    });
  }

  Future<void> _handleTabChange(int index) async {
    if (!mounted) return;

    // Animate tab immediately without transition
    _tabController.animateTo(index, duration: Duration.zero);

    // Start loading
    setState(() {
      _isChangingTab = true;
    });

    // Wait at least 1 second before hiding loading indicator
    await Future.delayed(const Duration(seconds: 1));

    // Update URL for web navigation after loading completes
    // This prevents hash change handlers from interfering
    if (kIsWeb && mounted) {
      String tabName;
      switch (index) {
        case 0:
          tabName = 'all';
          break;
        case 1:
          tabName = 'ongoing';
          break;
        case 2:
          tabName = 'upcoming';
          break;
        case 3:
          tabName = 'inactive';
          break;
        default:
          tabName = 'all';
      }
      try {
        // Use replaceState to avoid adding to history during loading
        PlatformSpecificUtils.replaceState('/#/vouchers/$tabName');
      } catch (e) {
        // Silently handle error
      }
    }

    // Hide loading indicator after the delay
    if (mounted) {
      setState(() {
        _isChangingTab = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning from other screens)
    if (mounted) {
      cubit.refresh();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check to prevent disposed engine error
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<VoucherScreenCubit, VoucherScreenState>(
      builder: (context, state) {
        // If there's an error or the state is not properly initialized, show a fallback
        if (state.processState == ProcessState.failure) {
          return _buildErrorState(context);
        }

        return BlocListener<VoucherScreenCubit, VoucherScreenState>(
          listener: (context, state) {
            if (!mounted) return;

            if (state.processState == ProcessState.success) {
              SnackbarService.showSuccess(
                context,
                state.dialogName.getLocalizedName(context),
                state.notifyMessage.getLocalizedMessage(context),
              );
                        cubit.toIdle();
            } else if (state.processState == ProcessState.failure) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => InformationDialog(
                    title: state.dialogName.getLocalizedName(context),
                    content: state.notifyMessage.getLocalizedMessage(context),
                    onPressed: () {
                      if (mounted) {
                        cubit.initialize();
                      }
                    },
                  ),
                );
              }
            }
          },
          child: _buildMainContent(context, state),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GradientText(text: S.of(context).voucher),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).errorLoadingVouchers,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).tryAgain,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  cubit.initialize();
                }
              },
              child: Text(S.of(context).refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, VoucherScreenState state) {
    final content = Scaffold(
      body: Column(
        children: [
          // Tab bar with add button
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    onTap: (index) {
                      _handleTabChange(index);
                    },
                    tabs: [
                      Tab(text: S.of(context).all),
                      Tab(text: S.of(context).ongoing),
                      Tab(text: S.of(context).upcoming),
                      Tab(text: S.of(context).inactive),
                    ],
                  ),
                ),
                // Add button next to tabs
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GradientIconButton(
                    icon: Icons.add,
                    onPressed: () async {
                      if (mounted) {
                        final result =
                            await AddVoucherScreen.showModal(context);
                        if (mounted) {
                          if (result == true) {
                            SnackbarService.showSuccess(
                              context,
                              S.of(context).success,
                              S.of(context).voucherAddedSuccess,
                            );
                            await cubit.refresh();
                          }
                        }
                      }
                    },
                    fillColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: state.processState == ProcessState.loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state.voucherList.isEmpty &&
                        state.processState == ProcessState.idle
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).noVouchersAvailable,
                              style: AppTextStyle.smallText,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  cubit.initialize();
                                }
                              },
                              child: Text(S.of(context).refresh),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          TabBarView(
                        controller: _tabController,
                            physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // All Vouchers Tab
                          _buildVoucherList(
                            context,
                            state.voucherList,
                            state.selectedVoucher,
                            (voucher) => cubit.setSelectedVoucher(voucher),
                          ),

                          // Ongoing Vouchers Tab
                          _buildVoucherList(
                            context,
                            state.ongoingList,
                            state.selectedVoucher,
                            (voucher) => cubit.setSelectedVoucher(voucher),
                          ),

                          // Upcoming Vouchers Tab
                          _buildVoucherList(
                            context,
                            state.upcomingList,
                            state.selectedVoucher,
                            (voucher) => cubit.setSelectedVoucher(voucher),
                          ),

                          // Inactive Vouchers Tab
                          _buildVoucherList(
                            context,
                            state.inactiveList,
                            state.selectedVoucher,
                            (voucher) => cubit.setSelectedVoucher(voucher),
                              ),
                            ],
                          ),
                          // Show loading indicator overlay during tab change
                          if (_isChangingTab)
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
        ],
      ),
    );

    // Web layout with header and sidebar
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
                        currentIndex: 4, // Voucher index
                        initialCompactMode: shouldAutoCompact,
                        onItemSelected: (value) {
                          _closeMobileSidebar();
                          if (!mounted) return;

                          // Handle sidebar navigation using Navigator
                          try {
                            if (value == 0) {
                              Navigator.pushReplacementNamed(context, '/main');
                            } else if (value == 1) {
                              Navigator.pushReplacementNamed(context, '/main');
                            } else if (value == 2) {
                              Navigator.pushReplacementNamed(context, '/invoices');
                            } else if (value == 3) {
                              Navigator.pushReplacementNamed(
                                  context, '/stakeholders');
                            } else if (value == 5) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                            // value == 4 (Voucher) is handled by staying in current screen
                          } catch (e) {
                            // Error in sidebar navigation
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
                        currentIndex: 4, // Voucher index
                        hideCollapseButton: true,
                        onItemSelected: (value) {
                          _closeMobileSidebar();
                          if (!mounted) return;

                          // Handle sidebar navigation using Navigator
                          try {
                            if (value == 0) {
                              Navigator.pushReplacementNamed(context, '/main');
                            } else if (value == 1) {
                              Navigator.pushReplacementNamed(context, '/main');
                            } else if (value == 2) {
                              Navigator.pushReplacementNamed(context, '/invoices');
                            } else if (value == 3) {
                              Navigator.pushReplacementNamed(
                                  context, '/stakeholders');
                            } else if (value == 5) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                            // value == 4 (Voucher) is handled by staying in current screen
                          } catch (e) {
                            // Error in sidebar navigation
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

  Widget _buildVoucherList(
    BuildContext context,
    List<Voucher> vouchers,
    Voucher? selectedVoucher,
    Function(Voucher) onVoucherSelected,
  ) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).noVouchersAvailable,
              style: AppTextStyle.smallText,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return GestureDetector(
          onTap: () async {
            if (mounted) {
              onVoucherSelected(voucher);
              final result =
                  await VoucherDetailScreen.showModal(context, voucher);
              if (mounted) {
                if (result == true) {
                  await cubit.refresh();
                }
              }
            }
          },
          onLongPress: () {
            if (mounted) {
              onVoucherSelected(voucher);
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    content: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Text(
                              voucher.voucherName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.visibility_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(S.of(context).view),
                            onTap: () async {
                              if (mounted) {
                                Navigator.pop(context);
                                final result =
                                    await VoucherDetailScreen.showModal(
                                        context, voucher);
                                if (mounted && result == true) {
                                  await cubit.refresh();
                                }
                              }
                            },
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              voucher.isEnabled
                                  ? Icons.not_interested
                                  : Icons.check,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            title: Text(
                              voucher.isEnabled
                                  ? S.of(context).disabled
                                  : S.of(context).enabled,
                            ),
                            onTap: () async {
                              if (mounted) {
                                Navigator.pop(context);
                                await cubit
                                    .toggleVoucherStatus(voucher.voucherID!);
                                if (mounted) {
                                  await cubit.refresh();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).then((_) {
                if (mounted) {
                  cubit.setSelectedVoucher(null);
                }
              });
            }
          },
          child: Column(
            children: [
              VoucherCard(
                voucher: voucher,
                isSelected: selectedVoucher == voucher,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
