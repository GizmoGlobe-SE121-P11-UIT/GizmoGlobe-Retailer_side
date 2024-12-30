import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_state.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_tab/product_tab_view.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../objects/product_related/product.dart';
import '../../../widgets/general/gradient_dropdown.dart';
import '../add_product/add_product_view.dart';

class ProductScreen extends StatefulWidget {
  final List<Product>? initialProducts;

  const ProductScreen({super.key, this.initialProducts});

  static Widget newInstance({List<Product>? initialProducts}) => BlocProvider(
    create: (context) => ProductScreenCubit(),
    child: ProductScreen(initialProducts: initialProducts),
  );

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  ProductScreenCubit get cubit => context.read<ProductScreenCubit>();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    tabController = TabController(length: getTabCount(), vsync: this);
    cubit.initialize(widget.initialProducts ?? []);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int getTabCount() => CategoryEnum.nonEmptyValues.length + 1;

  void onTabChanged(int index) {
    cubit.updateSelectedTabIndex(index);
  }

  Future<bool> _onWillPop() async {
    if (searchFocusNode.hasFocus) {
      searchFocusNode.unfocus();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: FieldWithIcon(
              height: 40,
              controller: searchController,
              focusNode: searchFocusNode,
              hintText: 'Find your item',
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
              onChanged: (value) {
                cubit.updateSearchText(value);
              },
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen.newInstance(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: const BoxDecoration(),
              tabs: [
                const Tab(text: 'All'),
                ...CategoryEnum.nonEmptyValues
                    .map((category) => Tab(
                  text: category.toString(),
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
                    ProductTab.newInstance(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newRam(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newCpu(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newPsu(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newGpu(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newDrive(searchText: state.searchText, initialProducts: state.initialProducts),
                    ProductTab.newMainboard(searchText: state.searchText, initialProducts: state.initialProducts),
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