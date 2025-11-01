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

  @override
  State<VoucherScreenWebView> createState() => _VoucherScreenWebViewState();
}

class _VoucherScreenWebViewState extends State<VoucherScreenWebView>
    with SingleTickerProviderStateMixin {
  VoucherScreenCubit get cubit => context.read<VoucherScreenCubit>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize cubit immediately
    cubit.initialize();

    // Set the initial tab if provided
    if (widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.animateTo(widget.initialTabIndex!);
        }
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
              'Error loading vouchers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  cubit.initialize();
                }
              },
              child: const Text('Refresh'),
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
                      if (!mounted) return;

                      // Update URL for web navigation
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
                        PlatformSpecificUtils.pushState('/#/vouchers/$tabName');
                      } catch (e) {
                        // Silently handle error
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
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
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
          ),
        ],
      ),
    );

    // Web layout with header and sidebar
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
                  currentIndex: 4, // Voucher index
                  onItemSelected: (value) {
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
                      if (kDebugMode) {
                        print('Error in sidebar navigation: $e');
                      }
                    }
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
