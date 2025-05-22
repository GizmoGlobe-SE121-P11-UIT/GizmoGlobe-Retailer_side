import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/app_text_style.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../../widgets/voucher/voucher_widget.dart';
import '../main/main_screen/main_screen_view.dart';

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
          title: const GradientText(text: "Voucher"),
          bottom: TabBar(
            controller: tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabAlignment: TabAlignment.fill,
            indicator: const BoxDecoration(),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Expired'),
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
                        MaterialPageRoute(builder: (context) => VoucherScreen.newInstance())
                        );
                    },
                  ),
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Tab 1: All voucher list
                    state.voucherList.isEmpty
                        ? const Center(
                            child: Text(
                              'No vouchers available',
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.voucherList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.voucherList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {},
                              );
                            },
                          ),
                    // Tab 2: Ongoing voucher list
                    state.ongoingList.isEmpty
                        ? const Center(
                            child: Text(
                              'No vouchers available',
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.ongoingList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.ongoingList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {},
                              );
                            },
                          ),
                    // Tab 3: Upcoming voucher list
                    state.upcomingList.isEmpty
                        ? const Center(
                            child: Text(
                              'No vouchers available',
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.upcomingList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.upcomingList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {},
                              );
                            },
                          ),
                    // Tab 4: Inactive voucher list
                    state.expiredList.isEmpty
                        ? const Center(
                            child: Text(
                              'No vouchers available',
                              style: AppTextStyle.regularText,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.expiredList.length,
                            itemBuilder: (context, index) {
                              final voucher = state.expiredList[index];
                              return VoucherWidget(
                                voucher: voucher,
                                onPressed: () {},
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