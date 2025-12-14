import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/product_related/product_extensions.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_webview.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../enums/stakeholders/manufacturer_status.dart';
import '../../../functions/helper.dart';
import '../../../objects/product_related/product.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../data/database/database.dart';
import '../../../widgets/general/status_badge.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../widgets/invoice/rating_card.dart';
import '../../product/add_product/add_product_view.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  static Widget newInstance(Product product) => BlocProvider(
        create: (context) => ProductDetailCubit(product),
        child: kIsWeb
            ? ProductDetailWebView.newInstance(product)
            : ProductDetailScreen(product: product),
      );

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
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
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                      ),
                      child: _buildImageCarousel(context, state),
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
                          _buildPriceSection(
                            importPrice: state.product.importPrice,
                            sellingPrice: state.product.sellingPrice,
                            discount: state.product.discount,
                          ),
                          const SizedBox(height: 24),
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

                          // Ratings section (mobile)
                          _buildRatingSection(state),

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
                                  title: state.dialogName
                                      .getLocalizedName(context),
                                  content: state.notifyMessage
                                      .getLocalizedMessage(context),
                                  onPressed: () {},
                                ));
                      } else if (state.processState == ProcessState.failure) {
                        showDialog(
                            context: context,
                            builder: (context) => InformationDialog(
                                  title: state.dialogName
                                      .getLocalizedName(context),
                                  content: state.notifyMessage
                                      .getLocalizedMessage(context),
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
                                    final result =
                                        await AddProductScreen.showModal(
                                      context,
                                      product: state.product,
                                    );
                                    if (result == true && mounted) {
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
// Only show enable/disable button if manufacturer is active
// If manufacturer is inactive, product will be displayed as discontinued
// and we don't want to allow changing its status
                              if (state.product.manufacturer.status !=
                                  ManufacturerStatus.inactive) ...[
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: state.product.status ==
                                              ProductStatusEnum.discontinued
                                          ? Theme.of(context)
                                              .colorScheme
                                              .tertiary
                                          : Theme.of(context).colorScheme.error,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildImageCarousel(BuildContext context, ProductDetailState state) {
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
        // Image with arrows
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _imagePageController,
                itemCount: images.length,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
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
              // Left arrow
              if (_currentImageIndex > 0)
                Positioned(
                  left: 8,
                  child: IconButton(
                    onPressed: () {
                      _imagePageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 20, color: colorScheme.onSurface),
                    ),
                  ),
                ),
              // Right arrow
              if (_currentImageIndex < images.length - 1)
                Positioned(
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      _imagePageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios,
                          size: 20, color: colorScheme.onSurface),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Indicator dots below image
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
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
          ),
      ],
    );
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
          // Import Price Row
          Row(
            children: [
              Icon(Icons.file_download_outlined,
                  size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                '${S.of(context).importPrice}: ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Helper.toCurrencyFormat(importPrice),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Selling Price Section - split into 2 lines to prevent overflow
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

// Ratings section for mobile product detail
  Widget _buildRatingSection(ProductDetailState state) {
    final ratings = state.ratings;
    final hasRatings = ratings.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings & Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Average summary (no highlight)
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
                        ? '${state.totalRatingsCount} reviews'
                        : 'No ratings yet',
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
              for (final r in ratings) ...[
                if (kDebugMode)
                  Text('DEBUG: rating ${r.ratingID} reply=${r.reply != null}'),
                RatingCard(
                  rating: r,
                  onPostReply: (ratingId, comment, {productId}) async {
                    // delegate to ProductDetailCubit and then pop to signal parent
                    if (kDebugMode) {
                      print('ProductDetailScreen: posting reply for $ratingId');
                    }
                    try {
                      await cubit.replyToRating(
                          ratingId: ratingId,
                          comment: comment,
                          productId: r.productID);
                      if (kDebugMode) {
                        print(
                            'ProductDetailScreen: reply posted, popping with success (scheduled)');
                      }
                      if (context.mounted) {
                        // schedule the pop to avoid navigator locked assertion during rebuild
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            Navigator.of(context).pop(ProcessState.success);
                          }
                        });
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('ProductDetailScreen: error posting reply: $e');
                      }
                      rethrow;
                    }
                  },
                ),
              ],
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
                child: const Text('Show more'),
              ),
            ),
          ),
      ],
    );
  }
}
