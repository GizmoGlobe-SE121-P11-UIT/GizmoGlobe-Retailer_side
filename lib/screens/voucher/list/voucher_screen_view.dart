import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_state.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_view.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../enums/processing/process_state_enum.dart';
import '../../../../widgets/dialog/information_dialog.dart';
import '../../../../widgets/general/app_text_style.dart';
import '../../../data/database/database.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/voucher/voucher_widget.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => VoucherScreenCubit(),
        child: const VoucherScreen(),
      );

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with SingleTickerProviderStateMixin {
  VoucherScreenCubit get cubit => context.read<VoucherScreenCubit>();
  late TabController tabController;

  // String _getTabTitle(BuildContext context, OrderOption option) {
  //   switch (option) {
  //     case OrderOption.toShip:
  //       return S.of(context).toShip;
  //     case OrderOption.toReceive:
  //       return S.of(context).toReceive;
  //     case OrderOption.completed:
  //       return S.of(context).completed;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          //title: GradientText(text: S.of(context).orders),
          title: GradientText(text: S.of(context).voucher),
          actions: [
            FutureBuilder<bool>(
              future: Database().isUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: GradientIconButton(
                      icon: Icons.add,
                      iconSize: 32,
                      onPressed: () async {
                        ProcessState result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddVoucherScreen.newInstance(),
                          ),
                        );

                        // if (result == ProcessState.success) {
                        //   cubit.initialize(Database().productList);
                        // }
                      },
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
          bottom: TabBar(
            controller: tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabAlignment: TabAlignment.fill,
            indicator: const BoxDecoration(),
            tabs: [
              Tab(text: S.of(context).all),
              Tab(text: S.of(context).ongoing),
              Tab(text: S.of(context).upcoming),
              Tab(text: S.of(context).inactive),
            ],
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<VoucherScreenCubit, VoucherScreenState>(
            listener: (context, state) {
              if (state.processState == ProcessState.success) {
                showDialog(
                  context: context,
                  builder: (context) => InformationDialog(
                    // title: S.of(context).orderConfirmed,
                    // content: S.of(context).deliveryConfirmed,
                    title: state.dialogName.description,
                    content: state.dialogMessage,
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  VoucherScreen.newInstance()));
                    },
                  ),
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Tab 1: All voucher list
                    state.voucherList.isEmpty
                        ? Center(
                            child: Text(
                              S.of(context).noVouchersAvailable,
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.voucherList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.voucherList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VoucherDetailScreen.newInstance(
                                              voucher),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    // Tab 2: Ongoing voucher list
                    state.ongoingList.isEmpty
                        ? Center(
                            child: Text(
                              S.of(context).noVouchersAvailable,
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.ongoingList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.ongoingList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VoucherDetailScreen.newInstance(
                                              voucher),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    // Tab 3: Upcoming voucher list
                    state.upcomingList.isEmpty
                        ? Center(
                            child: Text(
                              S.of(context).noVouchersAvailable,
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.upcomingList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.upcomingList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VoucherDetailScreen.newInstance(
                                              voucher),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    // Tab 4: Inactive voucher list
                    state.inactiveList.isEmpty
                        ? Center(
                            child: Text(
                              S.of(context).noVouchersAvailable,
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.inactiveList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.inactiveList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VoucherDetailScreen.newInstance(
                                              voucher),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
