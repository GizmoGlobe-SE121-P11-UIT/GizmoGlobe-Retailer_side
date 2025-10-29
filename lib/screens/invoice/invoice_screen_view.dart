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
        create: (context) => InvoiceScreenCubit(),
        child: InvoiceScreenWithInitialTab(initialTabIndex: initialTabIndex),
      );

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceScreenCubit, InvoiceScreenState>(
      builder: (context, state) {
        final content = DefaultTabController(
          length: 3,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: TabBar(
                  onTap: (index) {
                    context.read<InvoiceScreenCubit>().changeTab(index);

                    // Update URL for web navigation
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
                      PlatformSpecificUtils.pushState('/#/invoices/$tabName');
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
                child: IndexedStack(
                  index: state.selectedTabIndex,
                  children: [
                    SalesScreen.newInstance(),
                    IncomingScreen.newInstance(),
                    WarrantyScreen.newInstance(),
                  ],
                ),
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
                          // Handle sidebar navigation using Navigator
                          if (value == 0) {
                            Navigator.pushReplacementNamed(context, '/main');
                          } else if (value == 1) {
                            Navigator.pushReplacementNamed(context, '/main');
                          } else if (value == 3) {
                            Navigator.pushReplacementNamed(
                                context, '/stakeholders');
                          } else if (value == 4) {
                            Navigator.pushReplacementNamed(
                                context, '/vouchers');
                          } else if (value == 5) {
                            Navigator.pushReplacementNamed(context, '/main');
                          }
                          // value == 2 (Invoice) is handled by staying in current screen
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
          context.read<InvoiceScreenCubit>().changeTab(widget.initialTabIndex!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(InvoiceScreenWithInitialTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab when initialTabIndex changes (e.g., from URL change)
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<InvoiceScreenCubit>().changeTab(widget.initialTabIndex!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const InvoiceScreen(showFullLayout: true);
  }
}
