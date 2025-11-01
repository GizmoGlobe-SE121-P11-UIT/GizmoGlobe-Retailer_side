import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/stakeholders/manufacturer_status.dart';
import '../../../objects/product_related/product.dart';
import '../../../objects/product_related/product_extensions.dart';
import '../../../data/database/database.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/general/status_badge.dart';
import '../../../widgets/snackbar/snackbar_service.dart';
import '../../product/add_product/add_product_webview.dart';

class ProductDetailWebView extends StatefulWidget {
  final Product product;

  const ProductDetailWebView({super.key, required this.product});

  static Widget newInstance(Product product) => BlocProvider(
        create: (context) => ProductDetailCubit(product),
        child: ProductDetailWebView(product: product),
      );

  @override
  State<ProductDetailWebView> createState() => _ProductDetailWebViewState();
}

class _ProductDetailWebViewState extends State<ProductDetailWebView> {
  ProductDetailCubit get cubit => context.read<ProductDetailCubit>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = BlocConsumer<ProductDetailCubit, ProductDetailState>(
      listener: (context, state) {
        if (state.processState == ProcessState.success) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {},
            ),
          );
        } else if (state.processState == ProcessState.failure) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;
            if (isDesktop) {
              return _buildDesktopLayout(context, state);
            }
            return _buildMobileLayout(context, state);
          },
        );
      },
    );

    // On web, the route wrapper already renders header + sidebar; return content directly
    if (kIsWeb) return content;

    // Mobile (and non-web) fallback with its own AppBar
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: false,
        title: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => GradientText(
            text: state.product.productName,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              if (kIsWeb) {
                String tab;
                switch (widget.product.category) {
                  case CategoryEnum.ram:
                    tab = 'ram';
                    break;
                  case CategoryEnum.cpu:
                    tab = 'cpu';
                    break;
                  case CategoryEnum.psu:
                    tab = 'psu';
                    break;
                  case CategoryEnum.gpu:
                    tab = 'gpu';
                    break;
                  case CategoryEnum.drive:
                    tab = 'drive';
                    break;
                  case CategoryEnum.mainboard:
                    tab = 'mainboard';
                    break;
                  default:
                    tab = 'all';
                }
                PlatformSpecificUtils.replaceState('/#/product/$tab');
                // Navigate back to product tab listing and rebuild route
                Navigator.pushReplacementNamed(context, '/product');
              } else {
                Navigator.pop(context, ProcessState.idle);
              }
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ProductDetailState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: image panel
                    Expanded(
                      flex: 5,
                      child: Card(
                        elevation: 0,
                        color: colorScheme.surface,
                        child: AspectRatio(
                          aspectRatio: 16 / 12,
                          child: _buildProductImage(context, state),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right: info panel
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeading(
                              context, S.of(context).basicInformation),
                          const SizedBox(height: 8),
                          _buildNameRow(context, state),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            icon: Icons.category,
                            title: S.of(context).category,
                            value: _getLocalizedCategory(
                                context, state.product.category),
                          ),
                          _buildInfoRow(
                            context,
                            icon: Icons.business,
                            title: S.of(context).manufacturer,
                            value: state.product.manufacturer.manufacturerName,
                          ),
                          const SizedBox(height: 16),
                          _buildHeading(context, S.of(context).overview),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              StatusBadge(status: state.product.displayStatus),
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
                            context,
                            icon: Icons.calendar_today,
                            title: S.of(context).releaseDate,
                            value: DateFormat('dd/MM/yyyy')
                                .format(state.product.release),
                          ),
                          const SizedBox(height: 16),
                          _buildHeading(
                              context,
                              '${S.of(context).categorySpecifications} : '
                              '${_getLocalizedCategory(context, state.product.category)}'),
                          const SizedBox(height: 8),
                          ..._buildProductSpecificDetails(
                              context, state.product, state.technicalSpecs),
                          const SizedBox(height: 16),
                          _buildHeading(
                              context, S.of(context).productDescription),
                          const SizedBox(height: 8),
                          if (state.product.enDescription != null &&
                              state.product.enDescription!.isNotEmpty)
                            _buildDescriptionBlock(
                              context,
                              title: S.of(context).enDescription,
                              text: state.product.enDescription!,
                            ),
                          if (state.product.viDescription != null &&
                              state.product.viDescription!.isNotEmpty)
                            _buildDescriptionBlock(
                              context,
                              title: S.of(context).viDescription,
                              text: state.product.viDescription!,
                            ),
                          const SizedBox(height: 24),
                          _buildRatingsSection(context),
                          const SizedBox(
                              height: 100), // space for sticky footer
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildAdminActions(context, state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ProductDetailState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                color: colorScheme.surface,
                child: _buildProductImage(context, state),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading(context, S.of(context).basicInformation),
                    const SizedBox(height: 8),
                    _buildNameRow(context, state),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: Icons.category,
                      title: S.of(context).category,
                      value: _getLocalizedCategory(
                          context, state.product.category),
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.business,
                      title: S.of(context).manufacturer,
                      value: state.product.manufacturer.manufacturerName,
                    ),
                    const SizedBox(height: 16),
                    _buildHeading(context, S.of(context).overview),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusBadge(status: state.product.displayStatus),
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
                      context,
                      icon: Icons.calendar_today,
                      title: S.of(context).releaseDate,
                      value: DateFormat('dd/MM/yyyy')
                          .format(state.product.release),
                    ),
                    const SizedBox(height: 16),
                    _buildHeading(
                      context,
                      '${S.of(context).categorySpecifications} : '
                      '${_getLocalizedCategory(context, state.product.category)}',
                    ),
                    const SizedBox(height: 8),
                    ..._buildProductSpecificDetails(
                        context, state.product, state.technicalSpecs),
                    const SizedBox(height: 16),
                    _buildHeading(context, S.of(context).productDescription),
                    const SizedBox(height: 8),
                    if (state.product.enDescription != null &&
                        state.product.enDescription!.isNotEmpty)
                      _buildDescriptionBlock(
                        context,
                        title: S.of(context).enDescription,
                        text: state.product.enDescription!,
                      ),
                    if (state.product.viDescription != null &&
                        state.product.viDescription!.isNotEmpty)
                      _buildDescriptionBlock(
                        context,
                        title: S.of(context).viDescription,
                        text: state.product.viDescription!,
                      ),
                    const SizedBox(height: 24),
                    _buildRatingsSection(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildAdminActions(context, state),
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, ProductDetailState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = state.product.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Stack(
            children: [
              Center(child: child),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.05),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
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
      );
    }
    return Center(
      child: Icon(
        _getCategoryIcon(state.product.category),
        size: 64,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildHeading(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildNameRow(BuildContext context, ProductDetailState state) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  state.product.productName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
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
              context,
              _getLocalizedSpecKey(context, entry.key),
              entry.value,
            ))
        .toList();
  }

  Widget _buildSpecificationRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
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

  Widget _buildDescriptionBlock(
    BuildContext context, {
    required String title,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, ProductDetailState state) {
    return FutureBuilder<bool>(
      future: Database().isUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          final isManufacturerActive =
              state.product.manufacturer.status != ManufacturerStatus.inactive;
          return Container(
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: AddProductWebView.editInstance(state.product),
                        ),
                      );

                      if (result == true && mounted) {
                        cubit.updateProduct();
                        // Show success snackbar
                        SnackbarService.showSuccess(
                          context,
                          S.of(context).success,
                          S.of(context).productUpdatedSuccess,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      S.of(context).edit,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (isManufacturerActive) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cubit.toLoading();
                        cubit.changeProductStatus();
                      },
                      icon: Icon(
                        state.product.status == ProductStatusEnum.discontinued
                            ? Icons.refresh
                            : Icons.cancel,
                        color: Colors.white,
                      ),
                      label: Text(
                        state.product.status == ProductStatusEnum.discontinued
                            ? S.of(context).reactivate
                            : S.of(context).discontinue,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.product.status ==
                                ProductStatusEnum.discontinued
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading(context, 'Ratings & Reviews'),
        const SizedBox(height: 12),
        // Summary row
        Row(
          children: [
            Icon(Icons.star, color: colorScheme.tertiary, size: 20),
            const SizedBox(width: 4),
            Text(
              '4.7',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text('(123 reviews)',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        // Mock comments list
        Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('User ${index + 1}',
                              style: Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          Row(
                              children: List.generate(5, (i) {
                            return Icon(
                              i < 4 ? Icons.star : Icons.star_border,
                              size: 16,
                              color: colorScheme.tertiary,
                            );
                          })),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This is a placeholder review for demonstration purposes.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2025-10-31',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      // Owner reply placeholder
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.store_mall_directory,
                              color: colorScheme.primary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shop reply',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.primary),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Reply placeholder from the shop owner to the customer review.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(CategoryEnum category) {
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
