import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_series.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/socket.dart';
import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_gen.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_version.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_dropdown.dart';
import 'package:gizmoglobe_client/widgets/general/multi_field_with_icon.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:intl/intl.dart';
import '../../../data/database/database.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../../enums/product_related/drive_enums/drive_type.dart';
import '../../../enums/product_related/drive_enums/interface_type.dart';
import '../../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../../enums/product_related/psu_enums/psu_modular.dart';
import '../../../enums/product_related/ram_enums/ram_type.dart';
import '../../../objects/manufacturer.dart';
import '../../../objects/product_related/product.dart';
import '../../../objects/product_related/product_image.dart';
import '../../media/image_manager_modal.dart';
import 'add_product_state.dart';
import 'add_product_cubit.dart';

class AddProductWebView extends StatefulWidget {
  final Product? product;

  const AddProductWebView({super.key, this.product});

  static Widget addInstance() => BlocProvider(
        create: (context) => AddProductCubit(),
        child: const AddProductWebView(),
      );

  static Widget editInstance(Product product) => BlocProvider(
        create: (context) => AddProductCubit(product: product),
        child: AddProductWebView(product: product),
      );

  @override
  State<AddProductWebView> createState() => _AddProductWebViewState();
}

class _AddProductWebViewState extends State<AddProductWebView> {
  final _formKey = GlobalKey<FormState>();
  bool _isClosing = false;

  // Controllers for text input fields
  late final TextEditingController productNameController;
  late final TextEditingController importPriceController;
  late final TextEditingController sellingPriceController;
  late final TextEditingController discountController;
  late final TextEditingController stockController;
  late final TextEditingController enDescriptionController;
  late final TextEditingController viDescriptionController;

  // Cache for category-specific controllers
  final Map<String, TextEditingController> _controllerCache = {};

  AddProductCubit get cubit => context.read<AddProductCubit>();

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController();
    importPriceController = TextEditingController();
    sellingPriceController = TextEditingController();
    discountController = TextEditingController();
    stockController = TextEditingController();
    enDescriptionController = TextEditingController();
    viDescriptionController = TextEditingController();

    // Initialize from cubit state if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          context.read<AddProductCubit>().state.productArgument != null) {
        final state = context.read<AddProductCubit>().state;
        final arg = state.productArgument;
        if (arg != null) {
          productNameController.text = arg.productName ?? '';
          importPriceController.text = arg.importPrice?.toString() ?? '';
          sellingPriceController.text = arg.sellingPrice?.toString() ?? '';
          discountController.text = arg.discount?.toString() ?? '';
          stockController.text = arg.stock?.toString() ?? '';
          enDescriptionController.text = arg.enDescription ?? '';
          viDescriptionController.text = arg.viDescription ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    importPriceController.dispose();
    sellingPriceController.dispose();
    discountController.dispose();
    stockController.dispose();
    enDescriptionController.dispose();
    viDescriptionController.dispose();
    // Dispose cached controllers
    for (var controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
    super.dispose();
  }

  // Helper method to get or create a controller for a specific field
  TextEditingController _getController(String fieldKey, String? initialValue) {
    if (!_controllerCache.containsKey(fieldKey)) {
      _controllerCache[fieldKey] = TextEditingController(text: initialValue);
    } else if (_controllerCache[fieldKey]!.text != initialValue &&
        initialValue != null) {
      _controllerCache[fieldKey]!.text = initialValue;
    }
    return _controllerCache[fieldKey]!;
  }

  void _safeClose(dynamic result) {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      buildWhen: (previous, current) =>
          previous.processState != current.processState ||
          previous.images != current.images ||
          previous.isUploadingImage != current.isUploadingImage ||
          previous.productArgument != current.productArgument,
      listener: (context, state) {
        if (state.processState == ProcessState.success) {
          if (state.notifyMessage == NotifyMessage.msg21) {
            // Description generation - show dialog to notify
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
          } else {
            // Product add/edit success - close and let parent show snackbar
            _safeClose(true);
          }
        } else if (state.processState == ProcessState.failure) {
          // Show error dialog in webview
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
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.95,
          constraints: const BoxConstraints(
            maxWidth: 1400,
            maxHeight: 1000,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: state.processState == ProcessState.loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : _buildContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AddProductState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_box,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GradientText(
              text: widget.product == null
                  ? S.of(context).addProduct
                  : S.of(context).editProduct,
            ),
          ),
          if (state.processState == ProcessState.loading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          else
            GradientIconButton(
              icon: Icons.check,
              onPressed: () => cubit.addProduct(),
              fillColor: Colors.transparent,
            ),
          const SizedBox(width: 8),
          GradientIconButton(
            icon: Icons.close,
            onPressed: () => _safeClose(null),
            fillColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AddProductState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(state),
              const SizedBox(height: 24),
              _buildBasicInformationSection(state),
              const SizedBox(height: 24),
              _buildAdditionalInformationSection(state),
              if (state.productArgument?.category != null &&
                  state.productArgument?.category != CategoryEnum.empty)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildCategorySpecificationsSection(state),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(AddProductState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = state.activeImages;
    final imageCount = images.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => ImageManagerModal.show(context),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: colorScheme.surface,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (imageCount > 0)
                // Show image carousel/grid preview
                Row(
                  children: [
                    // Primary image (larger)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImageWidget(
                            images.first,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // Thumbnails column (if more than 1 image)
                    if (imageCount > 1)
                      SizedBox(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 1;
                                  i < (imageCount > 4 ? 3 : imageCount);
                                  i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageWidget(
                                      images[i],
                                      width: 80,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (imageCount > 3)
                                Container(
                                  width: 80,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${imageCount - 3}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).addProductImage,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click to manage images',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              // Image count badge
              if (imageCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$imageCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Loading overlay
              if (state.isUploadingImage || state.isLoadingImages)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              // Edit button
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Manage',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to display ProductImage - handles both pending (memory) and uploaded (network) images
  Widget _buildImageWidget(
    ProductImage image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (image.hasPendingUpload && image.pendingBytes != null) {
      // Pending image - use memory
      return Image.memory(
        image.pendingBytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: colorScheme.error,
              size: width != null ? width / 2 : 48,
            ),
          );
        },
      );
    } else if (image.url.isNotEmpty) {
      // Uploaded image - use network
      return Image.network(
        image.url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: colorScheme.error,
              size: width != null ? width / 2 : 48,
            ),
          );
        },
      );
    } else {
      // No image data available
      return Container(
        width: width,
        height: height,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported,
          color: colorScheme.onSurfaceVariant,
          size: width != null ? width / 2 : 48,
        ),
      );
    }
  }

  Widget _buildBasicInformationSection(AddProductState state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).basicInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildInputWidget<String>(
              S.of(context).productName,
              productNameController,
              state.productArgument?.productName,
              (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit.updateProductArgument(
                    currentArg.copyWith(productName: value));
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).importPrice,
                    importPriceController,
                    state.productArgument?.importPrice,
                    (value) {
                      final currentArg = cubit.state.productArgument;
                      if (currentArg == null) return;
                      cubit.updateProductArgument(
                          currentArg.copyWith(importPrice: value));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).sellingPrice,
                    sellingPriceController,
                    state.productArgument?.sellingPrice,
                    (value) {
                      final currentArg = cubit.state.productArgument;
                      if (currentArg == null) return;
                      cubit.updateProductArgument(
                          currentArg.copyWith(sellingPrice: value));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildInputWidget<String>(
                    S.of(context).discount,
                    discountController,
                    state.productArgument?.discount?.toString(),
                    (value) {
                      final currentArg = cubit.state.productArgument;
                      if (currentArg == null) return;
                      double? parsed;
                      if (value != null && value.isNotEmpty) {
                        parsed = double.tryParse(value);
                      }
                      cubit.updateProductArgument(
                          currentArg.copyWith(discount: parsed));
                    },
                    null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).stock,
                    stockController,
                    state.productArgument?.stock,
                    (value) {
                      final currentArg = cubit.state.productArgument;
                      if (currentArg == null) return;
                      final newStatus = (value ?? 0) > 0
                          ? ProductStatusEnum.active
                          : ProductStatusEnum.outOfStock;
                      cubit.updateProductArgument(currentArg.copyWith(
                          stock: value ?? 0, status: newStatus));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInformationSection(AddProductState state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).additionalInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildInputWidget<DateTime>(
              S.of(context).releaseDate,
              TextEditingController(),
              state.productArgument?.release ?? DateTime.now(),
              (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit
                    .updateProductArgument(currentArg.copyWith(release: value));
              },
            ),
            const SizedBox(height: 16),
            buildInputWidget<CategoryEnum>(
              S.of(context).category,
              TextEditingController(),
              state.productArgument?.category ?? CategoryEnum.cpu,
              (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit.updateProductArgument(
                    currentArg.copyWith(category: value));
              },
              CategoryEnum.getValues(),
            ),
            const SizedBox(height: 16),
            buildInputWidget<Manufacturer>(
              S.of(context).manufacturer,
              TextEditingController(),
              state.productArgument?.manufacturer,
              (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit.updateProductArgument(
                    currentArg.copyWith(manufacturer: value));
              },
              Database().manufacturerList,
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(S.of(context).status, style: AppTextStyle.smallText),
                const SizedBox(height: 8),
                BlocBuilder<AddProductCubit, AddProductState>(
                  builder: (context, state) {
                    final status = (state.productArgument?.stock ?? 0) > 0
                        ? ProductStatusEnum.active
                        : ProductStatusEnum.outOfStock;
                    final colorScheme = Theme.of(context).colorScheme;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: status == ProductStatusEnum.active
                            ? colorScheme.tertiary.withValues(alpha: 0.1)
                            : colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: status == ProductStatusEnum.active
                              ? colorScheme.tertiary
                              : colorScheme.error,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == ProductStatusEnum.active
                                ? Icons.check_circle
                                : Icons.error,
                            color: status == ProductStatusEnum.active
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == ProductStatusEnum.active
                                ? S.of(context).active
                                : S.of(context).outOfStock,
                            style: TextStyle(
                              color: status == ProductStatusEnum.active
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificationsSection(AddProductState state) {
    final enDescriptionController =
        TextEditingController(text: state.productArgument?.enDescription ?? '');
    final viDescriptionController =
        TextEditingController(text: state.productArgument?.viDescription ?? '');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${S.of(context).categorySpecifications} ${state.productArgument?.category.toString()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildCategorySpecificInputs(
              state.productArgument?.category ?? CategoryEnum.empty,
              state,
              cubit,
            ),
            MultiFieldWithIcon(
              controller: enDescriptionController,
              hintText: S.of(context).enterField(S.of(context).enDescription),
              labelText: S.of(context).enDescription,
              onChanged: (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit.updateProductArgument(
                    currentArg.copyWith(enDescription: value));
              },
              suffixIcon: (state.productArgument?.isEnEmpty ?? true) &&
                      (state.productArgument?.isViEmpty ?? true)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () {
                cubit.generateEnDescription();
              },
            ),
            const SizedBox(height: 16),
            MultiFieldWithIcon(
              controller: viDescriptionController,
              hintText: S.of(context).enterField(S.of(context).viDescription),
              labelText: S.of(context).viDescription,
              onChanged: (value) {
                final currentArg = cubit.state.productArgument;
                if (currentArg == null) return;
                cubit.updateProductArgument(
                    currentArg.copyWith(viDescription: value));
              },
              suffixIcon: (state.productArgument?.isEnEmpty ?? true) &&
                      (state.productArgument?.isViEmpty ?? true)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () {
                cubit.generateViDescription();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySpecificInputs(
      CategoryEnum category, AddProductState state, AddProductCubit cubit) {
    switch (category) {
      case CategoryEnum.ram:
        return Column(key: const ValueKey('ram_fields'), children: [
          buildInputWidget<RAMType>(
              'RAM type', TextEditingController(), state.productArgument?.type,
              (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(type: value));
          }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'RAM bus',
            _getController('ram_bus', state.productArgument?.bus?.toString()),
            state.productArgument?.bus,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(bus: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Capacity per stick (GB)',
            _getController(
                'ram_capacity', state.productArgument?.capacity?.toString()),
            state.productArgument?.capacity,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(capacity: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Kit stick count',
            _getController('ram_stickCount',
                state.productArgument?.stickCount?.toString()),
            state.productArgument?.stickCount,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(
                  currentArg.copyWith(stickCount: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'CL Latency',
            _getController(
                'ram_clLatency', state.productArgument?.clLatency?.toString()),
            state.productArgument?.clLatency,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit
                  .updateProductArgument(currentArg.copyWith(clLatency: value));
            },
          ),
          const SizedBox(height: 8),
        ]);

      case CategoryEnum.cpu:
        return Column(key: const ValueKey('cpu_fields'), children: [
          buildInputWidget<CPUSeries>('CPU series', TextEditingController(),
              state.productArgument?.cpuSeries, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(cpuSeries: value));
          }, CPUSeries.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Number of CPU cores',
            _getController('cpu_core', state.productArgument?.core?.toString()),
            state.productArgument?.core,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(core: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Number of CPU threads',
            _getController(
                'cpu_thread', state.productArgument?.thread?.toString()),
            state.productArgument?.thread,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(thread: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<double>(
              'CPU base clock speed (GHz)',
              _getController('cpu_baseClock',
                  state.productArgument?.baseClock?.toString()),
              state.productArgument?.baseClock, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(baseClock: value));
          }),
          const SizedBox(height: 8),
          buildInputWidget<double>(
              'CPU turbo clock speed (GHz)',
              _getController('cpu_turboClock',
                  state.productArgument?.turboClock?.toString()),
              state.productArgument?.turboClock, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(turboClock: value));
          }),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'CPU TDP (W)',
            _getController('cpu_tdp', state.productArgument?.tdp?.toString()),
            state.productArgument?.tdp,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(tdp: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<Socket>('CPU socket', TextEditingController(),
              state.productArgument?.socket, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(socket: value));
          }, Socket.getValues()),
          const SizedBox(height: 8),
        ]);
      case CategoryEnum.psu:
        return Column(key: const ValueKey('psu_fields'), children: [
          buildInputWidget<int>(
            'Max wattage (W)',
            _getController(
                'psu_maxWattage', state.productArgument?.tdp?.toString()),
            state.productArgument?.tdp,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(tdp: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<PSUEfficiency>(
              'PSU efficiency',
              TextEditingController(),
              state.productArgument?.efficiency, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(efficiency: value));
          }, PSUEfficiency.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<PSUModular>(
              'PSU modularity',
              TextEditingController(),
              state.productArgument?.modularity, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(modularity: value));
          }, PSUModular.getValues()),
          const SizedBox(height: 8),
          ...buildConnectorFields(state, cubit),
        ]);
      case CategoryEnum.gpu:
        return Column(key: const ValueKey('gpu_fields'), children: [
          buildInputWidget<GPUSeries>('GPU series', TextEditingController(),
              state.productArgument?.gpuSeries, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(gpuSeries: value));
          }, GPUSeries.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<GPUVersion>('GPU version', TextEditingController(),
              state.productArgument?.gpuVersion, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(gpuVersion: value));
          }, GPUVersion.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'GPU memory (GB)',
            _getController(
                'gpu_capacity', state.productArgument?.capacity?.toString()),
            state.productArgument?.capacity,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(capacity: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'GPU TDP (W)',
            _getController('gpu_tdp', state.productArgument?.tdp?.toString()),
            state.productArgument?.tdp,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(tdp: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<double>(
              'GPU boost clock (GHz)',
              _getController('gpu_turboClock',
                  state.productArgument?.turboClock?.toString()),
              state.productArgument?.turboClock, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(turboClock: value));
          }),
          const SizedBox(height: 8),
          ...buildIOPortFields(state, cubit),
        ]);
      case CategoryEnum.mainboard:
        return Column(key: const ValueKey('mainboard_fields'), children: [
          buildInputWidget<String>(
              'Chipset code',
              _getController(
                  'mb_chipsetCode', state.productArgument?.chipsetCode),
              state.productArgument?.chipsetCode, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit
                .updateProductArgument(currentArg.copyWith(chipsetCode: value));
          }),
          const SizedBox(height: 8),
          buildInputWidget<MainboardFormFactor>(
              'Mainboard form factor',
              TextEditingController(),
              state.productArgument?.mainboardFormFactor, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(
                currentArg.copyWith(mainboardFormFactor: value));
          }, MainboardFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'RAM bus speed (MHz)',
            _getController('mb_bus', state.productArgument?.bus?.toString()),
            state.productArgument?.bus,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(bus: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<RAMType>('Supported RAM type',
              TextEditingController(), state.productArgument?.type, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(type: value));
          }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
              'Maximum single RAM capacity (GB)',
              _getController(
                  'mb_capacity', state.productArgument?.capacity?.toString()),
              state.productArgument?.capacity, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(capacity: value));
          }),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Number of M.2 slots',
            _getController('mb_m2',
                state.productArgument?.storageSlot?.m2Slots.toString()),
            state.productArgument?.storageSlot?.m2Slots,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(
                  storageSlot:
                      currentArg.storageSlot?.copyWith(m2Slots: value)));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Number of SATA ports',
            _getController('mb_sata',
                state.productArgument?.storageSlot?.sataPorts.toString()),
            state.productArgument?.storageSlot?.sataPorts,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(
                  storageSlot:
                      currentArg.storageSlot?.copyWith(sataPorts: value)));
            },
          ),
          const SizedBox(height: 8),
          ...buildIOPortFields(state, cubit),
          const SizedBox(height: 8),
          ...buildPCIeSlotFields(state, cubit),
        ]);
      case CategoryEnum.drive:
        return Column(key: const ValueKey('drive_fields'), children: [
          buildInputWidget<DriveGen>('Drive generation',
              TextEditingController(), state.productArgument?.gen, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(gen: value));
          }, DriveGen.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<DriveType>('Drive type', TextEditingController(),
              state.productArgument?.driveType, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(currentArg.copyWith(driveType: value));
          }, DriveType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Capacity (GB)',
            _getController(
                'drive_capacity', state.productArgument?.capacity?.toString()),
            state.productArgument?.capacity,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(capacity: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<InterfaceType>(
            'Interface type',
            TextEditingController(),
            state.productArgument?.interfaceType,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(
                  currentArg.copyWith(interfaceType: value));
            },
            InterfaceType.getValues(),
          ),
          const SizedBox(height: 8),
          buildInputWidget<DriveFormFactor>(
              'Drive form factor',
              TextEditingController(),
              state.productArgument?.driveFormFactor, (value) {
            final currentArg = cubit.state.productArgument;
            if (currentArg == null) return;
            cubit.updateProductArgument(
                currentArg.copyWith(driveFormFactor: value));
          }, DriveFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Read speed (MB/s)',
            _getController(
                'drive_readMbps', state.productArgument?.readMbps?.toString()),
            state.productArgument?.readMbps,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit.updateProductArgument(currentArg.copyWith(readMbps: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            'Write speed (MB/s)',
            _getController('drive_writeMbps',
                state.productArgument?.writeMbps?.toString()),
            state.productArgument?.writeMbps,
            (value) {
              final currentArg = cubit.state.productArgument;
              if (currentArg == null) return;
              cubit
                  .updateProductArgument(currentArg.copyWith(writeMbps: value));
            },
          ),
          const SizedBox(height: 8),
        ]);
      default:
        return Container();
    }
  }

  List<Widget> buildConnectorFields(
      AddProductState state, AddProductCubit cubit) {
    final connectors = state.productArgument?.connectors ?? [];
    final List<Widget> widgets = [];

    for (int i = 0; i < connectors.length; i++) {
      widgets.add(Row(
        children: [
          Expanded(
            child: buildInputWidget<String>(
              'Connector type',
              TextEditingController(),
              i < connectors.length ? connectors[i].type : null,
              (value) {
                cubit.changeConnectorType(value, i);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildInputWidget<int>(
              'Quantity',
              TextEditingController(),
              i < connectors.length ? connectors[i].quantity : null,
              (value) {
                cubit.changeConnectorQuantity(value, i);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              // Handle remove
            },
          ),
        ],
      ));
    }

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Connector'),
        onPressed: () {
          // Handle add
        },
      ),
    ));

    return widgets;
  }

  List<Widget> buildIOPortFields(AddProductState state, AddProductCubit cubit) {
    final ioPorts = state.productArgument?.ioPorts ?? [];
    final List<Widget> widgets = [];

    for (int i = 0; i < ioPorts.length; i++) {
      widgets.add(Row(
        children: [
          Expanded(
              child: buildInputWidget<String>(
            'Port',
            TextEditingController(),
            i < ioPorts.length ? ioPorts[i].port : null,
            (value) {
              cubit.changeIoPortType(value, i);
            },
          )),
          const SizedBox(width: 8),
          Expanded(
              child: buildInputWidget<int>(
            'Quantity',
            TextEditingController(),
            i < ioPorts.length ? ioPorts[i].quantity : null,
            (value) {
              cubit.changeIoPortQuantity(value, i);
            },
          )),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              // Handle remove
            },
          ),
        ],
      ));
    }

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add IO Port'),
        onPressed: () {
          // Handle add
        },
      ),
    ));

    return widgets;
  }

  List<Widget> buildPCIeSlotFields(
      AddProductState state, AddProductCubit cubit) {
    final pcieSlots = state.productArgument?.pcieSlots ?? [];
    final List<Widget> widgets = [];

    for (int i = 0; i < pcieSlots.length; i++) {
      widgets.add(Row(
        children: [
          Expanded(
            child: buildInputWidget<int>(
              'Physical size',
              TextEditingController(),
              i < pcieSlots.length ? pcieSlots[i].physicalSize : null,
              (value) {
                cubit.changePCIeSlotPhysicalSize(value, i);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildInputWidget<int>(
              'Electrical speed',
              TextEditingController(),
              i < pcieSlots.length ? pcieSlots[i].electricalSpeed : null,
              (value) {
                cubit.changePCIeSlotElectricalSpeed(value, i);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildInputWidget<int>(
              'Generation',
              TextEditingController(),
              i < pcieSlots.length ? pcieSlots[i].gen : null,
              (value) {
                cubit.changePCIeSlotGen(value, i);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildInputWidget<int>(
              'Quantity',
              TextEditingController(),
              i < pcieSlots.length ? pcieSlots[i].quantity : null,
              (value) {
                cubit.changePCIeSlotQuantity(value, i);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () {
              // Handle remove
            },
          ),
        ],
      ));
    }

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add PCIe Slot'),
        onPressed: () {
          // Handle add
        },
      ),
    ));

    return widgets;
  }

  Widget buildInputWidget<T>(
      String propertyName,
      TextEditingController controller,
      T? propertyValue,
      void Function(T?) onChanged,
      [List<T>? enumValues]) {
    return Builder(builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      if (T == DateTime) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: propertyValue as DateTime? ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: colorScheme.primary,
                          onPrimary: colorScheme.onPrimary,
                          onSurface: colorScheme.onSurface,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  onChanged(picked as T?);
                }
              },
              child: AbsorbPointer(
                child: FieldWithIcon(
                  controller: TextEditingController(
                    text: (propertyValue as DateTime?) != null &&
                            propertyValue != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(propertyValue as DateTime)
                        : '',
                  ),
                  readOnly: true,
                  hintText: propertyName,
                  fillColor: colorScheme.surface,
                  suffixIcon: Icon(Icons.calendar_today,
                      color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        );
      } else if (enumValues != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            GradientDropdown<T>(
              items: (String filter, dynamic infiniteScrollProps) => enumValues,
              compareFn: (T? d1, T? d2) {
                if (d1 is Manufacturer && d2 is Manufacturer) {
                  return d1.manufacturerID == d2.manufacturerID;
                }
                return d1 == d2;
              },
              itemAsString: (T d) =>
                  d is Manufacturer ? d.manufacturerName : d.toString(),
              onChanged: (value) {
                if (value is Manufacturer) {
                  final selected =
                      (enumValues as List<Manufacturer>).firstWhere(
                    (m) => m.manufacturerID == value.manufacturerID,
                    orElse: () => value as Manufacturer,
                  );
                  onChanged(selected as T?);
                } else {
                  onChanged(value);
                }
              },
              selectedItem: propertyValue,
              hintText: propertyName,
            ),
          ],
        );
      } else {
        TextInputType keyboardType;
        List<TextInputFormatter> inputFormatters;

        if (T == int) {
          keyboardType = TextInputType.number;
          inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        } else if (T == double) {
          keyboardType = const TextInputType.numberWithOptions(decimal: true);
          inputFormatters = [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            if (propertyName == "Discount")
              TextInputFormatter.withFunction((oldValue, newValue) {
                if (newValue.text.isEmpty) return newValue;
                try {
                  final double? value = double.tryParse(newValue.text);
                  if (value != null && value > 1) {
                    return oldValue;
                  }
                } catch (_) {}
                return newValue;
              }),
          ];
        } else {
          keyboardType = TextInputType.text;
          inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'.*'))];
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            FieldWithIcon(
              key: ValueKey(propertyName),
              controller: controller,
              hintText: propertyName,
              onChanged: (value) {
                if (value.isEmpty) {
                  onChanged(null);
                } else if (T == int) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    onChanged(parsed as T?);
                  }
                } else if (T == double) {
                  if (value == '.' || value.endsWith('.')) return;
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    if (propertyName == "Discount" && parsed > 1) {
                      controller.text = "0";
                      onChanged(1.0 as T?);
                    } else {
                      onChanged(parsed as T?);
                    }
                  }
                } else {
                  onChanged(value as T?);
                }
              },
              fillColor: colorScheme.surface,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
            ),
          ],
        );
      }
    });
  }
}
