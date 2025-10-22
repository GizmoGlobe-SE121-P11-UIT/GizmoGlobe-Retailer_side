// lib/screens/main/main_screen/main_screen_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_view.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_in_screen/sign_in_view.dart';

import '../../../widgets/general/selectable_gradient_icon.dart';
import '../../../components/general/web_sidebar.dart';
import '../../home/home_screen/home_screen_view.dart';
import '../../user/user_screen/user_screen_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  MainScreenCubit get cubit => context.read<MainScreenCubit>();

  final List<Widget Function()> widgetList = [
    () => HomeScreen.newInstance(),
    () => ProductScreen.newInstance(),
    () => InvoiceScreen.newInstance(),
    () => StakeholderScreen.newInstance(),
    () => VoucherScreen.newInstance(),
    () => UserScreen.newInstance(),
  ];

  @override
  void initState() {
    super.initState();
    cubit.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL SECURITY: Check authentication directly in MainScreen
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    // ABSOLUTE WEB SECURITY: Block access if not authenticated
    if (kIsWeb && !isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Additional security: Block access if user is null or has no UID
    if (user == null || user.uid.isEmpty) {
      return SignInScreen.newInstance();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Web: use left sidebar; Mobile: keep bottom navigation
    if (kIsWeb) {
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
        body: Row(
          children: [
            WebSidebarModes(
              currentIndex: index,
              onItemSelected: (value) {
                if (value != index) {
                  setState(() {
                    index = value;
                  });
                }
              },
              items: items,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widgetList[index]()),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widgetList[index](),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            if (value != index) {
              setState(() {
                index = value;
              });
            }
          },
          currentIndex: index,
          backgroundColor: colorScheme.primary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 3,
          items: [
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.home,
                isSelected: index == 0,
                label: S.of(context).home, // Trang chủ
              ),
              label: S.of(context).home, // Trang chủ
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.inventory,
                isSelected: index == 1,
                label: S.of(context).product, // Sản phẩm
              ),
              label: S.of(context).product, // Sản phẩm
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.receipt,
                isSelected: index == 2,
                label: S.of(context).invoice, // Hóa đơn
              ),
              label: S.of(context).invoice, // Hóa đơn
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.groups,
                isSelected: index == 3,
                label: S.of(context).stakeholder,
              ),
              label: S.of(context).stakeholder,
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.discount,
                isSelected: index == 4,
                label: S.of(context).voucher,
              ),
              label: S.of(context).voucher,
            ),
            BottomNavigationBarItem(
              icon: SelectableGradientIcon(
                icon: Icons.account_circle,
                isSelected: index == 5,
                label: S.of(context).profile,
              ),
              label: S.of(context).profile,
            ),
          ],
        ),
      ),
    );
  }
}
