import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
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

import '../../../../enums/processing/process_state_enum.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => VoucherScreenCubit()..initialize(),
        child: const VoucherScreen(),
      );

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: GradientText(text: S.of(context).voucher),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GradientIconButton(
              icon: Icons.add,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVoucherScreen.newInstance(),
                  ),
                );
                cubit.initialize(); // Refresh the list after adding
              },
              fillColor: Colors.transparent,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).all),
            Tab(text: S.of(context).ongoing),
            Tab(text: S.of(context).upcoming),
            Tab(text: S.of(context).inactive),
          ],
        ),
      ),
      body: BlocConsumer<VoucherScreenCubit, VoucherScreenState>(
        listener: (context, state) {
          if (state.processState == ProcessState.success) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.getLocalizedName(context),
                content: state.dialogMessage,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          } else if (state.processState == ProcessState.failure) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.getLocalizedName(context),
                content: state.dialogMessage,
                onPressed: () {
                  cubit.initialize();
                },
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.processState == ProcessState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
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
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return GestureDetector(
          onTap: () async {
            onVoucherSelected(voucher);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VoucherDetailScreen.newInstance(voucher),
              ),
            );
            cubit.initialize(); // Refresh the list after returning
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
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VoucherDetailScreen.newInstance(voucher),
                              ),
                            );
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
          child: VoucherCard(
            voucher: voucher,
            isSelected: selectedVoucher == voucher,
          ),
        );
      },
    );
  }
}
