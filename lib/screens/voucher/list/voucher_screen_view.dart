import 'dart:html' as html;
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
import 'voucher_screen_webview.dart';

import '../../../../enums/processing/process_state_enum.dart';

class VoucherScreen extends StatefulWidget {
  final bool showFullLayout;
  final int? initialTabIndex;

  const VoucherScreen(
      {super.key, this.showFullLayout = false, this.initialTabIndex});

  static Widget newInstance() => BlocProvider(
        create: (context) => VoucherScreenCubit(),
        child: const VoucherScreen(showFullLayout: false),
      );

  static Widget newInstanceWithTab({int? initialTabIndex}) {
    if (kIsWeb) {
      return VoucherScreenWebView.newInstance(initialTabIndex: initialTabIndex);
    } else {
      return BlocProvider(
        create: (context) => VoucherScreenCubit(),
        child: VoucherScreenWithInitialTab(initialTabIndex: initialTabIndex),
      );
    }
  }

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with SingleTickerProviderStateMixin {
  VoucherScreenCubit get cubit => context.read<VoucherScreenCubit>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize cubit lazily
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cubit.initialize();
      }
    });

    // Set the initial tab if provided - only for web
    if (kIsWeb && widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(widget.initialTabIndex!);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For web, return minimal widget since webview is handled by newInstanceWithTab
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    return BlocConsumer<VoucherScreenCubit, VoucherScreenState>(
      listener: (context, state) {
        if (state.processState == ProcessState.success) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        } else if (state.processState == ProcessState.failure) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.initialize();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        final content = Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: GradientText(text: S.of(context).voucher),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GradientIconButton(
                  icon: Icons.add,
                  onPressed: () async {
                    if (kIsWeb) {
                      await AddVoucherScreen.showModal(context);
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddVoucherScreen.newInstance(),
                        ),
                      );
                    }
                    cubit.initialize(); // Refresh the list after adding
                  },
                  fillColor: Colors.transparent,
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                // Update URL for web navigation
                if (kIsWeb) {
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
                  html.window.history
                      .pushState(null, '', '/#/vouchers?tabs=$tabName');
                }
              },
              tabs: [
                Tab(text: S.of(context).all),
                Tab(text: S.of(context).ongoing),
                Tab(text: S.of(context).upcoming),
                Tab(text: S.of(context).inactive),
              ],
            ),
          ),
          body: state.processState == ProcessState.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  controller: _tabController,
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
                WebHeader(
                  unreadChats: 0,
                  isSidebarCompact: false,
                ),
                // Main content with sidebar
                Expanded(
                  child: Row(
                    children: [
                      WebSidebarModes(
                        currentIndex: 4, // Voucher index
                        onItemSelected: (value) {
                          // Handle sidebar navigation using Navigator
                          if (value == 0) {
                            Navigator.pushReplacementNamed(context, '/main');
                          } else if (value == 1) {
                            Navigator.pushReplacementNamed(context, '/main');
                          } else if (value == 2) {
                            Navigator.pushReplacementNamed(
                                context, '/invoices');
                          } else if (value == 3) {
                            Navigator.pushReplacementNamed(
                                context, '/stakeholders');
                          } else if (value == 5) {
                            Navigator.pushReplacementNamed(context, '/main');
                          }
                          // value == 4 (Voucher) is handled by staying in current screen
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
            onVoucherSelected(voucher);
            final result =
                await VoucherDetailScreen.showModal(context, voucher);
            if (result == ProcessState.success) {
              cubit.initialize();
            }
            cubit.initialize();
          },
          onLongPress: () {
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
                            Navigator.pop(context);
                            await VoucherDetailScreen.showModal(
                                context, voucher);
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
                          onTap: () {
                            Navigator.pop(context);
                            cubit.toggleVoucherStatus(voucher.voucherID!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).then((_) {
              cubit.setSelectedVoucher(null);
            });
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

// Widget to handle initial tab index for web navigation
class VoucherScreenWithInitialTab extends StatefulWidget {
  final int? initialTabIndex;

  const VoucherScreenWithInitialTab({super.key, this.initialTabIndex});

  @override
  State<VoucherScreenWithInitialTab> createState() =>
      _VoucherScreenWithInitialTabState();
}

class _VoucherScreenWithInitialTabState
    extends State<VoucherScreenWithInitialTab> {
  @override
  void initState() {
    super.initState();
    // Set the initial tab if provided - only for web
    if (kIsWeb && widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // The tab controller will be set in the VoucherScreen
          // We need to access it through the context
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VoucherScreen(
        showFullLayout: true, initialTabIndex: widget.initialTabIndex);
  }
}
