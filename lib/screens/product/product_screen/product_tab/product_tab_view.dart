import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/edit_product/edit_product_view.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/objects/product_related/product_extensions.dart';
import 'package:gizmoglobe_client/enums/stakeholders/manufacturer_status.dart';

import '../../../../data/database/database.dart';
import '../../../../enums/processing/process_state_enum.dart';
import '../../../../enums/processing/sort_enum.dart';
import '../../../../enums/product_related/category_enum.dart';
import '../../../../enums/product_related/product_status_enum.dart';
import '../../../../objects/product_related/filter_argument.dart';
import '../../../../objects/product_related/product.dart';
import '../../../../widgets/general/app_text_style.dart';
import '../../filter/filter_screen/filter_screen_view.dart';
import '../../mixin/product_tab_mixin.dart';
import '../../product_detail/product_detail_view.dart';
import 'product_tab_cubit.dart';
import 'product_tab_state.dart';
import '../../../../widgets/general/status_badge.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  static Widget newInstance(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => AllTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newRam(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => RamTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newCpu(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => CpuTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newPsu(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => PsuTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newGpu(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => GpuTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newDrive(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => DriveTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  static Widget newMainboard(
          {String? searchText, required List<Product> initialProducts}) =>
      BlocProvider<TabCubit>(
        create: (context) => MainboardTabCubit()
          ..initialize(const FilterArgument(),
              searchText: searchText, initialProducts: initialProducts),
        child: const ProductTab(),
      );

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab>
    with SingleTickerProviderStateMixin, TabMixin<ProductTab> {
  TabCubit get cubit => context.read<TabCubit>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              BlocBuilder<TabCubit, TabState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Text(
                        S.of(context).sortBy,
                        style: AppTextStyle.smallText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<SortEnum>(
                          isExpanded: true,
                          itemHeight: kMinInteractiveDimension,
                          value: state.selectedSortOption,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          underline: Container(
                            height: 1,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          onChanged: (SortEnum? newValue) {
                            if (newValue != null &&
                                newValue != state.selectedSortOption) {
                              cubit.updateSortOption(newValue);
                            }
                          },
                          items: SortEnum.values
                              .map<DropdownMenuItem<SortEnum>>(
                                  (SortEnum value) {
                                String displayText;
                                switch (value) {
                                  case SortEnum.salesHighest:
                                    displayText = S.of(context).salesHighest;
                                    break;
                                  case SortEnum.salesLowest:
                                    displayText = S.of(context).salesLowest;
                                    break;
                                  case SortEnum.releaseLatest:
                                    displayText = S.of(context).releaseLatest;
                                    break;
                                  case SortEnum.releaseOldest:
                                    displayText = S.of(context).releaseOldest;
                                    break;
                                  case SortEnum.stockHighest:
                                    displayText = S.of(context).stockHighest;
                                    break;
                                  case SortEnum.stockLowest:
                                    displayText = S.of(context).stockLowest;
                                    break;
                                }
                                return DropdownMenuItem<SortEnum>(
                                  value: value,
                                  child: Container(
                                    constraints: const BoxConstraints(minHeight: 40),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      displayText,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.filter_list_alt),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () async {
                            final FilterArgument arguments = state
                                .filterArgument
                                .copy(filter: state.filterArgument);

                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    FilterScreen.newInstance(
                                      arguments: arguments,
                                      selectedTabIndex: cubit.getIndex(),
                                      manufacturerList:
                                      cubit.getManufacturerList(),
                                    ),
                              ),
                            );

                            if (result is FilterArgument) {
                              cubit.updateFilter(
                                filter: result,
                              );
                              cubit.applyFilters();
                            }
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<TabCubit, TabState>(
                  builder: (context, state) {
                    if (state.filteredProductList.isEmpty) {
                      return Center(
                        child: Text(
                          S.of(context).noProductsFound,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.filteredProductList.length,
                      itemBuilder: (context, index) {
                        final product = state.filteredProductList[index];
                        final isSelected = state.selectedProduct == product;

                        IconData getCategoryIcon(CategoryEnum category) {
                          switch (category) {
                            case CategoryEnum.ram:
                              return Icons.memory;
                            case CategoryEnum.cpu:
                              return Icons.computer;
                            case CategoryEnum.psu:
                              return Icons.power;
                            case CategoryEnum.gpu:
                              return Icons.videogame_asset;
                            case CategoryEnum.drive:
                              return Icons.storage;
                            case CategoryEnum.mainboard:
                              return Icons.developer_board;
                            default:
                              return Icons.device_unknown;
                          }
                        }

                        return GestureDetector(
                          onTap: () async {
                            cubit.setSelectedProduct(null);
                            ProcessState result =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen.newInstance(product),
                              ),
                            );

                            if (result == ProcessState.success) {
                              await cubit.reloadProducts();
                            }
                          },
                          onLongPress: () async {
                            cubit.setSelectedProduct(product);
                            final bool isAdmin = await Database().isUserAdmin();

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
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 16, 8, 8),
                                          child: Text(
                                            product.productName,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          title: Text(S.of(context).view),
                                          onTap: () {
                                            Navigator.pop(context);
                                            cubit.setSelectedProduct(null);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetailScreen
                                                        .newInstance(product),
                                              ),
                                            );
                                          },
                                        ),
                                        if (isAdmin) ...[
                                          ListTile(
                                            dense: true,
                                            leading: Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            title: Text(S.of(context).edit),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              cubit.setSelectedProduct(null);
                                              ProcessState processState =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProductScreen
                                                          .newInstance(product),
                                                ),
                                              );

                                              if (processState ==
                                                  ProcessState.success) {
                                                await cubit.reloadProducts();
                                              }
                                            },
                                          ),
                                          // Only show the enable/disable option if manufacturer is active
                                          if (product.manufacturer.status != ManufacturerStatus.inactive)
                                          ListTile(
                                            dense: true,
                                            leading: Icon(
                                              product.status ==
                                                      ProductStatusEnum
                                                          .discontinued
                                                  ? Icons.check_circle_outline
                                                  : Icons.cancel_outlined,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            title: Text(
                                              product.status ==
                                                      ProductStatusEnum
                                                          .discontinued
                                                  ? S.of(context).activate
                                                  : S.of(context).deactivate,
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              cubit.toLoading();
                                              cubit.setSelectedProduct(null);

                                              await cubit.changeStatus(product);
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ).then((_) {
                              cubit.setSelectedProduct(null);
                            });
                          },
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: state.selectedProduct == null ||
                                    state.selectedProduct == product
                                ? 1.0
                                : 0.3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1) 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      getCategoryIcon(product.category),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        product.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      status: product.displayStatus,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<TabCubit, TabState>(
          builder: (context, state) {
            if (state.processState == ProcessState.loading) {
              return Stack(
                children: [
                  ModalBarrier(
                      dismissible: false, color: Colors.black.withValues(alpha: 0.5)), 
                  Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ]),
    );
  }
}
