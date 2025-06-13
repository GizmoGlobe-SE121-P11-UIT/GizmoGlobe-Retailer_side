import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/edit_product/edit_product_view.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:flutter/foundation.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../objects/product_related/product.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../data/database/database.dart';
import '../../../widgets/general/status_badge.dart';
import '../../../widgets/general/gradient_text.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  static Widget newInstance(Product product) => BlocProvider(
        create: (context) => ProductDetailCubit(product),
        child: ProductDetailScreen(product: product),
      );

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetailCubit get cubit => context.read<ProductDetailCubit>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => GradientIconButton(
            icon: Icons.chevron_left,
            onPressed: () => {
              if (widget.product != state.product)
                {Navigator.pop(context, ProcessState.success)}
              else
                {Navigator.pop(context, state.processState)}
            },
            fillColor: Colors.transparent,
          ),
        ),
        actions: const [],
        title: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => GradientText(
            text: state.product.productName,
          ),
        ),
      ),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (kDebugMode) {
            print('Product imageUrl: ${state.product.imageUrl}');
          }
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface, 
                      ),
                      child: (state.product.imageUrl != null &&
                              state.product.imageUrl!.isNotEmpty)
                          ? Image.network(
                              state.product.imageUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Stack(
                                  children: [
                                    Center(child: child),
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withValues(alpha: 0.05), 
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: colorScheme.primary,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    _getCategoryIcon(state.product.category),
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                _getCategoryIcon(state.product.category),
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),

                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          Text(
                            S.of(context).basicInformation,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        state.product.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          _buildInfoRow(
                            icon: Icons.category,
                            title: S.of(context).category,
                            value: _getLocalizedCategory(
                                context, state.product.category),
                          ),

                          _buildInfoRow(
                            icon: Icons.business,
                            title: S.of(context).manufacturer,
                            value: state.product.manufacturer.manufacturerName,
                          ),
                          // Thêm thông tin về giá và discount
                          _buildPriceSection(
                            sellingPrice: state.product.sellingPrice,
                            discount: state.product.discount,
                          ),
                          const SizedBox(height: 24),
                          // Status Information Section
                          Text(
                            S.of(context).overview,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              StatusBadge(status: state.product.status),
                              const SizedBox(width: 16),
                              Icon(
                                state.product.stock > 0
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: state.product.stock > 0
                                    ? colorScheme.tertiary
                                    : colorScheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${S.of(context).stock}: ${state.product.stock}',
                                style: TextStyle(
                                  color: state.product.stock > 0
                                      ? colorScheme.tertiary
                                      : colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            title: S.of(context).releaseDate,
                            value: DateFormat('dd/MM/yyyy')
                                .format(state.product.release),
                          ),

                          const SizedBox(height: 24),
                          // Technical Specifications Section
                          Text(
                            '${S.of(context).categorySpecifications} : ${_getLocalizedCategory(context, state.product.category)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),

                          ..._buildProductSpecificDetails(
                              context, state.product, state.technicalSpecs),

                          const SizedBox(height: 24),
                          Text(
                            S.of(context).productDescription,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (state.product.enDescription != null &&
                              state.product.enDescription!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).enDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.product.enDescription!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 8),
                          if (state.product.viDescription != null &&
                              state.product.viDescription!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).viDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.product.viDescription!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Add padding at bottom to prevent content from being hidden behind buttons
                          const SizedBox(
                              height: 80), // Height for the bottom buttons
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky footer with buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: BlocConsumer<ProductDetailCubit, ProductDetailState>(
                    listener: (context, state) {
                      if (state.processState == ProcessState.success) {
                        showDialog(
                            context: context,
                            builder: (context) => InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {},
                                ));
                      } else if (state.processState == ProcessState.failure) {
                        showDialog(
                            context: context,
                            builder: (context) => InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {
                                    cubit.toIdle();
                                  },
                                ));
                      }
                    },
                    builder: (context, state) => FutureBuilder<bool>(
                      future: Database().isUserAdmin(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    ProcessState processState =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProductScreen.newInstance(
                                                state.product),
                                      ),
                                    );

                                    if (processState == ProcessState.success) {
                                      cubit.updateProduct();
                                    }
                                  },
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                  label: Text(
                                    S.of(context).edit,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    cubit.toLoading();
                                    cubit.changeProductStatus();
                                  },
                                  icon: Icon(
                                    state.product.status ==
                                            ProductStatusEnum.discontinued
                                        ? Icons.refresh
                                        : Icons.cancel,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    state.product.status ==
                                            ProductStatusEnum.discontinued
                                        ? S.of(context).reactivate
                                        : S.of(context).discontinue,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.product.status ==
                                            ProductStatusEnum.discontinued
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(context).colorScheme.error,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(category) {
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductSpecificDetails(
      BuildContext context, Product product, Map<String, String> specs) {
    return specs.entries
        .map((entry) => _buildSpecificationRow(
            _getLocalizedSpecKey(context, entry.key), entry.value))
        .toList();
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection({
    required double sellingPrice,
    required double discount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final discountedPrice = sellingPrice * (1 - discount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.attach_money,
              size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            S.of(context).price,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          if (discount > 0) ...[
            Text(
              ': \$${sellingPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${discountedPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${(discount * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else
            Text(
              '\$${sellingPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  String _getLocalizedCategory(BuildContext context, CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return 'RAM';
      case CategoryEnum.cpu:
        return 'CPU';
      case CategoryEnum.psu:
        return 'PSU';
      case CategoryEnum.gpu:
        return 'GPU';
      case CategoryEnum.drive:
        return S.of(context).drive;
      case CategoryEnum.mainboard:
        return S.of(context).mainboard;
      default:
        return S.of(context).unknownCategory;
    }
  }

  String _getLocalizedSpecKey(BuildContext context, String key) {
    switch (key.toLowerCase()) {
      case 'type':
        return S.of(context).driveType;
      case 'capacity':
        return S.of(context).driveCapacity;
      case 'ram bus':
        return S.of(context).ramBus;
      case 'ram capacity':
        return S.of(context).ramCapacity;
      case 'ram type':
        return S.of(context).ramType;
      case 'cpu family':
        return S.of(context).cpuFamily;
      case 'cpu core':
        return S.of(context).cpuCore;
      case 'cpu thread':
        return S.of(context).cpuThread;
      case 'cpu clock speed':
        return S.of(context).cpuClockSpeed;
      case 'psu wattage':
        return S.of(context).psuWattage;
      case 'psu efficiency':
        return S.of(context).psuEfficiency;
      case 'psu modular':
        return S.of(context).psuModular;
      case 'gpu series':
        return S.of(context).gpuSeries;
      case 'gpu capacity':
        return S.of(context).gpuCapacity;
      case 'gpu bus':
        return S.of(context).gpuBus;
      case 'gpu clock speed':
        return S.of(context).gpuClockSpeed;
      case 'form factor':
        return S.of(context).formFactor;
      case 'series':
        return S.of(context).series;
      case 'compatibility':
        return S.of(context).compatibility;
      default:
        return key;
    }
  }
}
