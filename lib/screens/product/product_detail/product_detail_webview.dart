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
import '../../../functions/helper.dart';
import '../../product/add_product/add_product_webview.dart';
import '../../../widgets/invoice/rating_card.dart';

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
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  ProductDetailCubit get cubit => context.read<ProductDetailCubit>();

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = BlocConsumer<ProductDetailCubit, ProductDetailState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state.processState == ProcessState.success) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.getLocalizedName(context),
                content: state.notifyMessage.getLocalizedMessage(context),
                onPressed: () {},
              ),
            );
          }
        } else if (state.processState == ProcessState.failure) {
          if (context.mounted) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumbs at top
                    _buildBreadcrumbs(context, state),
                    const SizedBox(height: 16),

                    // 2-column layout: Image on left, Info on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column: Image carousel
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
                        const SizedBox(width: 24),
                        // Right column: Basic info, Overview, Specifications
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Information
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
                                value:
                                    state.product.manufacturer.manufacturerName,
                              ),
                              _buildInfoRow(
                                context,
                                icon: Icons.file_download_outlined,
                                title: S.of(context).importPrice,
                                value: Helper.toCurrencyFormat(
                                    state.product.importPrice),
                              ),
                              _buildPriceSection(
                                context,
                                importPrice: state.product.importPrice,
                                sellingPrice: state.product.sellingPrice,
                                discount: state.product.discount,
                              ),

                              const SizedBox(height: 16),
                              // Overview
                              _buildHeading(context, S.of(context).overview),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  StatusBadge(
                                      status: state.product.displayStatus),
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
                                  const SizedBox(width: 24),
                                  Icon(Icons.calendar_today,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${S.of(context).releaseDate}: ${DateFormat('dd/MM/yyyy').format(state.product.release)}',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              // Specifications
                              _buildHeading(
                                  context,
                                  '${S.of(context).categorySpecifications} : '
                                  '${_getLocalizedCategory(context, state.product.category)}'),
                              const SizedBox(height: 8),
                              ..._buildProductSpecificDetails(
                                  context, state.product, state.technicalSpecs),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Product Description - Full width below
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
                    const SizedBox(height: 100), // space for sticky footer
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: _buildBreadcrumbs(context, state),
              ),
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
                    // Import Price
                    _buildInfoRow(
                      context,
                      icon: Icons.file_download_outlined,
                      title: S.of(context).importPrice,
                      value: Helper.toCurrencyFormat(state.product.importPrice),
                    ),
                    // Selling Price with discount
                    _buildPriceSection(
                      context,
                      importPrice: state.product.importPrice,
                      sellingPrice: state.product.sellingPrice,
                      discount: state.product.discount,
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
    final images = state.imageUrls.isNotEmpty
        ? state.imageUrls
        : (state.product.imageUrl?.isNotEmpty == true
            ? [state.product.imageUrl!]
            : <String>[]);

    if (images.isEmpty) {
      return Center(
        child: Icon(
          _getCategoryIcon(state.product.category),
          size: 64,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        // Image carousel with arrow navigation
        Expanded(
          child: Stack(
            children: [
              // PageView with scrolling disabled
              PageView.builder(
                controller: _imagePageController,
                itemCount: images.length,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  if (!mounted) {
                    return const SizedBox.shrink();
                  }
                  final imageUrl = images[index];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (!mounted) {
                        return const SizedBox.shrink();
                      }
                      if (loadingProgress == null) return child;
                      return Stack(
                        children: [
                          // Category icon as placeholder
                          Center(
                            child: Icon(
                              _getCategoryIcon(state.product.category),
                              size: 64,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          // Loading indicator overlay
                          Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      if (!mounted) {
                        return const SizedBox.shrink();
                      }
                      return Center(
                        child: Icon(
                          _getCategoryIcon(state.product.category),
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  );
                },
              ),
              // Left arrow - hidden if on first image
              if (images.length > 1 && _currentImageIndex > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: colorScheme.surface.withValues(alpha: 0.8),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if (mounted && _imagePageController.hasClients) {
                            _imagePageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.chevron_left,
                            size: 28,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Right arrow - hidden if on last image
              if (images.length > 1 && _currentImageIndex < images.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: colorScheme.surface.withValues(alpha: 0.8),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if (mounted && _imagePageController.hasClients) {
                            _imagePageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.chevron_right,
                            size: 28,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Indicator dots - below the image with gap
        if (images.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 18 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ],
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
    // Convert specs to list of entries
    final entries = specs.entries.toList();

    // Calculate how many rows we need (2 items per row)
    final rowCount = (entries.length / 2).ceil();

    // Build 2-column layout
    return List.generate(rowCount, (rowIndex) {
      final leftIndex = rowIndex * 2;
      final rightIndex = leftIndex + 1;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column spec
            Expanded(
              child: _buildSpecificationItem(
                context,
                _getLocalizedSpecKey(context, entries[leftIndex].key),
                entries[leftIndex].value,
              ),
            ),
            const SizedBox(width: 16),
            // Right column spec (if exists)
            Expanded(
              child: rightIndex < entries.length
                  ? _buildSpecificationItem(
                      context,
                      _getLocalizedSpecKey(context, entries[rightIndex].key),
                      entries[rightIndex].value,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSpecificationItem(
      BuildContext context, String label, String value) {
    return Row(
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
        if (!mounted) return const SizedBox.shrink();
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
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final ratings = state.ratings;
        final hasRatings = ratings.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading(context, S.of(context).ratingsAndReviews),
            const SizedBox(height: 12),

            // Average summary
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (state.averageRating > 0)
                            ? state.averageRating.toStringAsFixed(1)
                            : '0.0',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        (state.totalRatingsCount > 0)
                            ? '${state.totalRatingsCount} ${S.of(context).reviews}'
                            : S.of(context).noRatingsYet,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Individual rating cards
            if (!hasRatings)
              const SizedBox()
            else
              Column(
                children: [
                  for (final r in ratings)
                    RatingCard(
                      rating: r,
                      onPostReply: (ratingId, comment, {productId}) async {
                        try {
                          await cubit.replyToRating(
                              ratingId: ratingId,
                              comment: comment,
                              productId: r.productID);
                          if (context.mounted) {
                            // schedule the pop to avoid navigator locked assertion during rebuild
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                Navigator.of(context).pop(ProcessState.success);
                              }
                            });
                          }
                        } catch (e) {
                          rethrow;
                        }
                      },
                    ),
                ],
              ),
            // Show more button
            if (state.hasMoreRatings)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await cubit.loadMoreRatings();
                    },
                    child: Text(S.of(context).showMore),
                  ),
                ),
              ),
          ],
        );
      },
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

  Widget _buildBreadcrumbs(BuildContext context, ProductDetailState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final tab = _getCategoryTab(state.product.category);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        TextButton(
          onPressed: () {
            // Replace hash to point to “all” so URL matches the product list
            PlatformSpecificUtils.replaceState('/#/product/');
            Navigator.pushReplacementNamed(context, '/product');
          },
          child: Text(
            S.of(context).products,
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        Icon(Icons.chevron_right,
            size: 18, color: colorScheme.onSurfaceVariant),
        TextButton(
          onPressed: () {
            PlatformSpecificUtils.pushState('/#/product/$tab');
          },
          child: Text(
            _getLocalizedCategory(context, state.product.category),
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        Icon(Icons.chevron_right,
            size: 18, color: colorScheme.onSurfaceVariant),
        Text(
          state.product.productName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getCategoryTab(CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return 'ram';
      case CategoryEnum.cpu:
        return 'cpu';
      case CategoryEnum.psu:
        return 'psu';
      case CategoryEnum.gpu:
        return 'gpu';
      case CategoryEnum.drive:
        return 'drive';
      case CategoryEnum.mainboard:
        return 'mainboard';
      default:
        return 'all';
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
    // Remove trailing colon if present
    final cleanKey = key.replaceAll(':', '').trim().toLowerCase();

    switch (cleanKey) {
      // RAM
      case 'type':
        return S.of(context).type;
      case 'bus':
        return S.of(context).bus;
      case 'cl latency':
        return S.of(context).clLatency;
      case 'kit stick count':
        return S.of(context).kitStickCount;
      case 'capacity per stick':
        return S.of(context).capacityPerStick;
      case 'ram bus':
        return S.of(context).ramBus;
      case 'ram capacity':
        return S.of(context).ramCapacity;
      case 'ram type':
        return S.of(context).ramType;

      // CPU
      case 'cores':
        return S.of(context).cores;
      case 'threads':
        return S.of(context).threads;
      case 'base clock':
        return S.of(context).baseClock;
      case 'turbo clock':
        return S.of(context).turboClock;
      case 'tdp':
        return S.of(context).tdp;
      case 'socket':
        return S.of(context).socket;
      case 'cpu family':
        return S.of(context).cpuFamily;
      case 'cpu core':
        return S.of(context).cpuCore;
      case 'cpu thread':
        return S.of(context).cpuThread;
      case 'cpu clock speed':
        return S.of(context).cpuClockSpeed;

      // GPU
      case 'version':
        return S.of(context).version;
      case 'memory':
        return S.of(context).memory;
      case 'clock speed':
        return S.of(context).clockSpeed;
      case 'i/o ports':
        return S.of(context).ioPorts;
      case 'gpu series':
        return S.of(context).gpuSeries;
      case 'gpu capacity':
        return S.of(context).gpuCapacity;
      case 'gpu bus':
        return S.of(context).gpuBus;
      case 'gpu clock speed':
        return S.of(context).gpuClockSpeed;

      // Mainboard
      case 'chipset':
        return S.of(context).chipset;
      case 'form factor':
        return S.of(context).formFactor;
      case 'ram spec':
        return S.of(context).ramSpec;
      case 'storage':
        return S.of(context).storage;
      case 'pcie slots':
        return S.of(context).pcieSlots;

      // Drive
      case 'drive type':
        return S.of(context).driveType;
      case 'generation':
        return S.of(context).generation;
      case 'capacity':
        return S.of(context).driveCapacity;
      case 'interface':
        return S.of(context).interfaceType;
      case 'read speed':
        return S.of(context).readSpeed;
      case 'write speed':
        return S.of(context).writeSpeed;

      // PSU
      case 'wattage':
        return S.of(context).psuWattage;
      case 'efficiency rating':
        return S.of(context).efficiencyRating;
      case 'modularity':
        return S.of(context).modularity;
      case 'connectors':
        return S.of(context).connectors;
      case 'psu wattage':
        return S.of(context).psuWattage;
      case 'psu efficiency':
        return S.of(context).psuEfficiency;
      case 'psu modular':
        return S.of(context).psuModular;

      // Other
      case 'series':
        return S.of(context).series;
      case 'compatibility':
        return S.of(context).compatibility;
      default:
        return key;
    }
  }

  Widget _buildPriceSection(
    BuildContext context, {
    required int importPrice,
    required int sellingPrice,
    required double discount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final discountedPrice = sellingPrice * (100 - discount) / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selling Price Row - First line: crossed price + discount tag
          Row(
            children: [
              Icon(Icons.file_upload_outlined,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${S.of(context).sellingPrice}: ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              if (discount > 0) ...[
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        Helper.toCurrencyFormat(sellingPrice),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${discount.toInt()}%',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Text(
                  Helper.toCurrencyFormat(sellingPrice),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          // Second line: Discounted price (only show if discount > 0)
          if (discount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text(
                Helper.toCurrencyFormat(discountedPrice),
                style: TextStyle(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
