import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_view.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/general/selectable_gradient_icon.dart';
import '../../home/home_screen/home_screen_view.dart';
import '../../user/user_screen/user_screen_view.dart';

class MainScreen extends StatefulWidget {
  static const MainScreen _instance = MainScreen._internal();
  static final GlobalKey<_MainScreenState> _key = GlobalKey<_MainScreenState>();

  factory MainScreen() {
    return _instance;
  }

  const MainScreen._internal();

  void setIndex(int newIndex) {
    _key.currentState?.setIndex(newIndex);
  }

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
        () => UserScreen.newInstance(),
  ];

  @override
  void initState() {
    super.initState();
    cubit.getUserName();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        index = prefs.getInt('mainScreenIndex') ?? 0;
      });
    }
  }

  Future<void> _saveIndex(int newIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mainScreenIndex', newIndex);
  }

  Future<void> _resetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mainScreenIndex');
    if (mounted) {
      setState(() {
        index = 0;
      });
    }
  }

  void setIndex(int newIndex) {
    if (mounted) {
      setState(() {
        index = newIndex;
      });
      _saveIndex(newIndex);
    }
  }

  @override
  void dispose() {
    _resetIndex();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 3,
              items: [
                BottomNavigationBarItem(
                  icon: SelectableGradientIcon(
                    icon: Icons.home,
                    isSelected: index == 0,
                    label: 'Home',
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: SelectableGradientIcon(
                    icon: Icons.inventory,
                    isSelected: index == 1,
                    label: 'Product',
                  ),
                  label: "Product",
                ),
                BottomNavigationBarItem(
                  icon: SelectableGradientIcon(
                    icon: Icons.receipt,
                    isSelected: index == 2,
                    label: 'Invoice',
                  ),
                  label: "Invoice",
                ),
                BottomNavigationBarItem(
                  icon: SelectableGradientIcon(
                    icon: Icons.groups,
                    isSelected: index == 3,
                    label: 'Stakeholder',
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: SelectableGradientIcon(
                    icon: Icons.account_circle,
                    isSelected: index == 4,
                    label: 'Profile',
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}