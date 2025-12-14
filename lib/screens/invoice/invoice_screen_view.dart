import 'package:gizmoglobe_client/screens/invoice/sales/rating_reply/rating_reply_view.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/rating_reply/rating_reply_webview.dart';
import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/invoice/incoming/incoming_screen_view.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_state.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/sales_screen_view.dart';
import 'package:gizmoglobe_client/screens/invoice/warranty/warranty_screen_view.dart';
import 'package:gizmoglobe_client/components/general/web_header.dart';
import 'package:gizmoglobe_client/components/general/web_sidebar.dart';

class InvoiceScreen extends StatefulWidget {
  final bool showFullLayout;

  const InvoiceScreen({super.key, this.showFullLayout = false});

  static Widget newInstance() => BlocProvider(
        create: (context) => InvoiceScreenCubit(),
        child: const InvoiceScreen(showFullLayout: false),
      );

  static Widget newInstanceWithTab({int? initialTabIndex}) => BlocProvider(
        create: (context) =>
            InvoiceScreenCubit(initialTabIndex: initialTabIndex),
        child: InvoiceScreenWithInitialTab(initialTabIndex: initialTabIndex),
      );

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Sync TabController with cubit state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<InvoiceScreenCubit>();
        if (_tabController.index != cubit.state.selectedTabIndex) {
          _tabController.animateTo(cubit.state.selectedTabIndex,
              duration: Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceScreenCubit, InvoiceScreenState>(
      listener: (context, state) {
        // Sync TabController with state
        if (_tabController.index != state.selectedTabIndex) {
          _tabController.animateTo(state.selectedTabIndex,
              duration: Duration.zero);
        }
      },
      child: BlocBuilder<InvoiceScreenCubit, InvoiceScreenState>(
        builder: (context, state) {
          final content = GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              floatingActionButton: state.selectedTabIndex == 0
                  ? FloatingActionButton(
                      onPressed: () {
                        if (kIsWeb) {
                          // Show modal on web
                          showDialog(
                            context: context,
                            builder: (_) => RatingReplyWebView.newInstance(),
                          );
                        } else {
                          // Navigate to screen on mobile
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => RatingReplyView.newInstance()),
                          );
                        }
                      },
                      tooltip: 'Open ratings',
                      child: const Icon(Icons.rate_review),
                    )
                  : null,
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: TabBar(
                  controller: _tabController,
                  onTap: (index) async {
                    // Animate tab immediately without transition
                    _tabController.animateTo(index, duration: Duration.zero);
                    await context.read<InvoiceScreenCubit>().changeTab(index);

                    // Update URL for web navigation
                    // Do this after loading completes to prevent hash change loop
                    if (kIsWeb) {
                      String tabName;
                      switch (index) {
                        case 0:
                          tabName = 'sales';
                          break;
                        case 1:
                          tabName = 'incoming';
                          break;
                        case 2:
                          tabName = 'warranty';
                          break;
                        default:
                          tabName = 'sales';
                      }
                      // Use replaceState to avoid adding to history during loading
                      PlatformSpecificUtils.replaceState(
                          '/#/invoices/$tabName');
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
                    Tab(text: S.of(context).sales),
                    Tab(text: S.of(context).incoming),
                    Tab(text: S.of(context).warranty),
                  ],
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: state.selectedTabIndex,
                      children: [
                        SalesScreen.newInstance(),
                        IncomingScreen.newInstance(),
                        WarrantyScreen.newInstance(),
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
                          currentIndex: 2, // Invoice index
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
class InvoiceScreenWithInitialTab extends StatefulWidget {
  final int? initialTabIndex;

  const InvoiceScreenWithInitialTab({super.key, this.initialTabIndex});

  @override
  State<InvoiceScreenWithInitialTab> createState() =>
      _InvoiceScreenWithInitialTabState();
}

class _InvoiceScreenWithInitialTabState
    extends State<InvoiceScreenWithInitialTab> {
  @override
  void initState() {
    super.initState();
    // Set the initial tab if provided - only for web
    if (kIsWeb && widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final cubit = context.read<InvoiceScreenCubit>();
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
  void didUpdateWidget(InvoiceScreenWithInitialTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab when initialTabIndex changes (e.g., from URL change)
    // Only update if not already changing tabs to prevent loops
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final cubit = context.read<InvoiceScreenCubit>();
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
    return const InvoiceScreen(showFullLayout: true);
  }
}
