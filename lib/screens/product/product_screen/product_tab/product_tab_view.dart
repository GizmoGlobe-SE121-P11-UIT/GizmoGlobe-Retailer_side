import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';

import '../../../../data/database/database.dart';
import '../../../../enums/processing/process_state_enum.dart';
import '../../../../enums/processing/sort_enum.dart';
import '../../../../enums/product_related/category_enum.dart';
import '../../../../enums/product_related/product_status_enum.dart';
import '../../../../objects/product_related/filter_argument.dart';
import '../../../../widgets/general/app_text_style.dart';
import '../../filter/filter_screen/filter_screen_view.dart';
import '../../mixin/product_tab_mixin.dart';
import '../../product_detail/product_detail_view.dart';
import 'product_tab_cubit.dart';
import 'product_tab_state.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  static Widget newInstance() => BlocProvider<TabCubit>(
    create: (context) => AllTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newRam() => BlocProvider<TabCubit>(
    create: (context) => RamTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newCpu() => BlocProvider<TabCubit>(
    create: (context) => CpuTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newPsu() => BlocProvider<TabCubit>(
    create: (context) => PsuTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newGpu() => BlocProvider<TabCubit>(
    create: (context) => GpuTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newDrive() => BlocProvider<TabCubit>(
    create: (context) => DriveTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  static Widget newMainboard() => BlocProvider<TabCubit>(
    create: (context) => MainboardTabCubit()..initialize(const FilterArgument()),
    child: const ProductTab(),
  );

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> with SingleTickerProviderStateMixin, TabMixin<ProductTab> {
  TabCubit get cubit => context.read<TabCubit>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              BlocBuilder<TabCubit, TabState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      const Text(
                        'Sort by: ',
                        style: AppTextStyle.smallText,
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<SortEnum>(
                        value: state.selectedSortOption,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onChanged: (SortEnum? newValue) {
                          if (newValue != null && newValue != state.selectedSortOption) {
                            cubit.updateSortOption(newValue);
                          }
                        },
                        items: SortEnum.values.map<DropdownMenuItem<SortEnum>>((SortEnum value) {
                          return DropdownMenuItem<SortEnum>(
                            value: value,
                            child: Row(
                              children: [
                                Text(value.toString()),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      Center(
                        child: GradientIconButton(
                          icon: Icons.filter_list_alt,
                          iconSize: 28,
                          onPressed: () async {
                            final FilterArgument arguments = state.filterArgument.copy(
                              filter: state.filterArgument
                            );

                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FilterScreen.newInstance(
                                  arguments: arguments,
                                  selectedTabIndex: cubit.getIndex(),
                                  manufacturerList: cubit.getManufacturerList(),
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
                    if (state.productList.isEmpty) {
                      return const Center(
                        child: Text('No products found'),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.productList.length,
                      itemBuilder: (context, index) {
                        final product = state.productList[index];
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
                          onTap: () {
                            cubit.setSelectedProduct(null);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen.newInstance(product),
                              ),
                            );
                          },
                          onLongPress: () {
                            cubit.setSelectedProduct(product);
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
                                              product.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.visibility_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            title: const Text('View'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              cubit.setSelectedProduct(null);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProductDetailScreen.newInstance(product),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            title: const Text('Edit'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              cubit.setSelectedProduct(null);
                                              final updatedProduct = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProductDetailScreen.newInstance(product),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            leading: Icon(
                                              product.status == ProductStatusEnum.discontinued
                                                  ? Icons.check_circle_outline
                                                  : Icons.cancel_outlined,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            title: product.status == ProductStatusEnum.discontinued
                                                ? const Text('Activate', style: TextStyle())
                                                : const Text('Discontinue', style: TextStyle()),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              cubit.toLoading();
                                              cubit.setSelectedProduct(null);

                                              await cubit.changeStatus(product);
                                            },
                                          ),
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
                            opacity: state.selectedProduct == null || state.selectedProduct == product ? 1.0 : 0.3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      getCategoryIcon(product.category),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            product.category.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: product.status == ProductStatusEnum.active
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product.status.toString(),
                                        style: TextStyle(
                                          color: product.status == ProductStatusEnum.active
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                    ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)),
                    const Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ]
      ),
    );
  }
}