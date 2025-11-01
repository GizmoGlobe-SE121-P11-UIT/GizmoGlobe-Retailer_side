import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/add_product/add_product_view.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_state.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_tab/product_tab_view.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';

import '../../../data/database/database.dart';
import '../../../enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import '../../../objects/product_related/product.dart';
import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/snackbar/snackbar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';

class ProductScreen extends StatefulWidget {
  final List<Product>? initialProducts;
  final int? initialTabIndex; // for web routing

  const ProductScreen({super.key, this.initialProducts, this.initialTabIndex});

  static Widget newInstance({List<Product>? initialProducts}) => BlocProvider(
        create: (context) => ProductScreenCubit(),
        child: ProductScreen(initialProducts: initialProducts),
      );

  static Widget newInstanceWithTab({int? initialTabIndex}) => BlocProvider(
        create: (context) => ProductScreenCubit(),
        child: ProductScreen(initialTabIndex: initialTabIndex),
      );

  static Widget newInstanceWithTabKey({int? initialTabIndex, Key? key}) =>
      BlocProvider(
        create: (context) => ProductScreenCubit(),
        child: ProductScreen(key: key, initialTabIndex: initialTabIndex),
      );

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  ProductScreenCubit get cubit => context.read<ProductScreenCubit>();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    // Create TabController with an initial index if provided (avoids animateTo on first frame)
    final int tabCount = CategoryEnum.getValues().length + 1;
    int safeInitialIndex = 0;
    if (widget.initialTabIndex != null) {
      final int idx = widget.initialTabIndex!;
      if (idx >= 0 && idx < tabCount) {
        safeInitialIndex = idx;
      }
    }
    tabController = TabController(
        length: tabCount, vsync: this, initialIndex: safeInitialIndex);
    cubit.initialize(widget.initialProducts ?? Database().productList);

    // Listen to tab index changes and push hash for web
    // (removed: handled via onTap to avoid duplicate navigation)
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    tabController.dispose();
    super.dispose();
  }

  String _tabNameForIndex(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'ram';
      case 2:
        return 'cpu';
      case 3:
        return 'psu';
      case 4:
        return 'gpu';
      case 5:
        return 'drive';
      case 6:
        return 'mainboard';
      default:
        return 'all';
    }
  }

  void _pushProductHash(int index) {
    if (!kIsWeb) return;
    final name = _tabNameForIndex(index);
    final currentUrl = PlatformSpecificUtils.getCurrentUrl();
    if (!currentUrl.endsWith('/#/product/$name')) {
      try {
        PlatformSpecificUtils.pushState('/#/product/$name');
      } catch (_) {}
    }
  }

  int getTabCount() => CategoryEnum.getValues().length + 1;

  void onTabChanged(int index) {
    cubit.updateSelectedTabIndex(index);
    _pushProductHash(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !searchFocusNode.hasFocus,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          searchFocusNode.unfocus();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: !kIsWeb,
            title: FieldWithIcon(
              height: 40,
              controller: searchController,
              focusNode: searchFocusNode,
              hintText: S.of(context).findProducts,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              onChanged: (value) {
                cubit.updateSearchText(searchController.text);
              },
            ),
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
                          final result =
                              await AddProductScreen.showModal(context);
                          if (result == true && mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              SnackbarService.showSuccess(
                                context,
                                S.of(context).success,
                                S.of(context).productAddedSuccess,
                              );
                              cubit.initialize(Database().productList);
                            });
                          }
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
              onTap: onTabChanged,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: const BoxDecoration(),
              tabs: [
                Tab(text: S.of(context).all),
                ...CategoryEnum.getValues().map((category) => Tab(
                      text: category.getLocalizedDescription(context),
                    )),
              ],
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<ProductScreenCubit, ProductScreenState>(
              builder: (context, state) {
                return TabBarView(
                  controller: tabController,
                  children: [
                    ProductTab.newInstance(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newRam(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newCpu(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newPsu(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newGpu(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newDrive(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                    ProductTab.newMainboard(
                        searchText: state.searchText,
                        initialProducts: state.initialProducts),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
