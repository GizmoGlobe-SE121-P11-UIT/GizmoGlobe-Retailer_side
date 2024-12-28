import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userRole = doc.data()?['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    tabs.add(const Tab(text: 'Customers'));
    tabViews.add(CustomersScreen.newInstance());

    if (userRole != 'employee') {
      tabs.add(const Tab(text: 'Employees'));
      tabViews.add(EmployeesScreen.newInstance());
    }

    tabs.add(const Tab(text: 'Vendors'));
    tabViews.add(VendorsScreen.newInstance());

    return BlocBuilder<StakeholderScreenCubit, StakeholderScreenState>(
      builder: (context, state) {
        return DefaultTabController(
          length: tabs.length,
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
                    tabs: tabs,
                  ),
                ),
              ),
              body: SafeArea(
                child: IndexedStack(
                  index: state.selectedTabIndex,
                  children: tabViews,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}