// lib/screens/main/main_screen/main_screen_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/stakeholder/customers/customers_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/employees/employees_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_state.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendors_screen_view.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import '../../../widgets/general/selectable_gradient_icon.dart';
import '../../widgets/general/gradient_text.dart';


class StakeholderScreen extends StatefulWidget {
  const StakeholderScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => StakeholderScreenCubit(),
        child: const StakeholderScreen(),
      );

  @override
  State<StakeholderScreen> createState() => _StakeholderScreenState();
}

class _StakeholderScreenState extends State<StakeholderScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakeholderScreenCubit, StakeholderScreenState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 3,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TabBar(
                    onTap: (index) {
                      context.read<StakeholderScreenCubit>().changeTab(index);
                    },
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: Theme.of(context).primaryColor,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Customers'),
                      Tab(text: 'Employees'),
                      Tab(text: 'Vendors'),
                    ],
                  ),
                ),
              ),
              body: SafeArea(
                child: IndexedStack(
                  index: state.selectedTabIndex,
                  children: [
                    CustomersScreen.newInstance(),
                    EmployeesScreen.newInstance(),
                    VendorsScreen.newInstance(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}