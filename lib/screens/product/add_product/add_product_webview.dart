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
import '../../../objects/product_related/mainboard_related/io_port.dart';
import '../../../objects/product_related/mainboard_related/pcie_slot.dart';
import '../../../objects/product_related/mainboard_related/storage_slot.dart';
import '../../../objects/product_related/psu_related/connector.dart';
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
  late final TextEditingController releaseDateController;

  // Category specific controllers
  // RAM
  late TextEditingController busController;
  late TextEditingController typeController;
  late TextEditingController stickCountController;
  late TextEditingController clLatencyController;
  late TextEditingController capacityController;

  // CPU
  late TextEditingController cpuSeriesController;
  late TextEditingController socketController;
  late TextEditingController coreController;
  late TextEditingController threadController;
  late TextEditingController baseClockController;
  late TextEditingController turboClockController;
  late TextEditingController tdpController;

  // PSU
  late TextEditingController maxWattageController;
  late TextEditingController efficiencyController;
  late TextEditingController modularityController;

  // GPU
  late TextEditingController gpuSeriesController;
  late TextEditingController gpuVersionController;

  // Mainboard
  late TextEditingController mainboardFormFactorController;
  late TextEditingController chipsetCodeController;
  StorageSlotControllers? storageSlotControllerSingle;
  late TextEditingController formFactorController;

  // Drive
  late TextEditingController genController;
  late TextEditingController interfaceTypeController;
  late TextEditingController writeMbpsController;
  late TextEditingController readMbpsController;
  late TextEditingController driveTypeController;
  late TextEditingController driveFormFactorController;

  // Controllers for list fields
  final List<ConnectorControllers> connectorControllers = [];
  final List<IOPortControllers> ioPortsControllers = [];
  final List<PCIeSlotControllers> pcieSlotsController = [];

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
    releaseDateController = TextEditingController();

    _initializeControllers();
  }

  void _initializeControllers() {
    final arg = cubit.state.productArgument;

    // Initialize explicit controllers (shared and specific)
    // Initialize shared/reused controllers first to avoid lateness issues if we were to init them conditionally
    // But since we use late, we must assign them.
    // We will assign all of them, using defaults or values from arg.

    // Helpers
    String s(dynamic v) => v?.toString() ?? '';

    // RAM
    busController = TextEditingController(text: s(arg?.bus));
    typeController = TextEditingController(text: s(arg?.type));
    stickCountController = TextEditingController(text: s(arg?.stickCount));
    clLatencyController = TextEditingController(text: s(arg?.clLatency));
    capacityController = TextEditingController(text: s(arg?.capacity));

    // CPU
    cpuSeriesController = TextEditingController(text: s(arg?.cpuSeries));
    socketController = TextEditingController(text: s(arg?.socket));
    coreController = TextEditingController(text: s(arg?.core));
    threadController = TextEditingController(text: s(arg?.thread));
    baseClockController = TextEditingController(text: s(arg?.baseClock));
    turboClockController = TextEditingController(text: s(arg?.turboClock));
    tdpController = TextEditingController(text: s(arg?.tdp));

    // PSU
    maxWattageController = TextEditingController(text: s(arg?.tdp)); // PSU uses tdp field for maxWattage? checking cubit... yes
    efficiencyController = TextEditingController(text: s(arg?.efficiency));
    modularityController = TextEditingController(text: s(arg?.modularity));

    // GPU
    gpuSeriesController = TextEditingController(text: s(arg?.gpuSeries));
    gpuVersionController = TextEditingController(text: s(arg?.gpuVersion));

    // Mainboard
    mainboardFormFactorController = TextEditingController(text: s(arg?.mainboardFormFactor));
    chipsetCodeController = TextEditingController(text: s(arg?.chipsetCode));
    // storageSlotControllerSingle
    if (arg?.storageSlot != null) {
      storageSlotControllerSingle = StorageSlotControllers(
        m2Slots: s(arg!.storageSlot!.m2Slots),
        sataPorts: s(arg.storageSlot!.sataPorts)
      );
    } else {
       storageSlotControllerSingle = StorageSlotControllers(m2Slots: '0', sataPorts: '0');
    }
    formFactorController = TextEditingController(); // unused?

    // Drive
    genController = TextEditingController(text: s(arg?.gen));
    interfaceTypeController = TextEditingController(text: s(arg?.interfaceType));
    writeMbpsController = TextEditingController(text: s(arg?.writeMbps));
    readMbpsController = TextEditingController(text: s(arg?.readMbps));
    driveTypeController = TextEditingController(text: s(arg?.driveType));
    driveFormFactorController = TextEditingController(text: s(arg?.driveFormFactor));

    if (arg == null) return;

    productNameController.text = arg.productName ?? '';
    importPriceController.text = arg.importPrice?.toString() ?? '';
    sellingPriceController.text = arg.sellingPrice?.toString() ?? '';
    discountController.text = arg.discount?.toString() ?? '';
    stockController.text = arg.stock?.toString() ?? '';
    enDescriptionController.text = arg.enDescription ?? '';
    viDescriptionController.text = arg.viDescription ?? '';
    releaseDateController.text = arg.release != null ? DateFormat('yyyy-MM-dd').format(arg.release!) : '';

    // Initialize list controllers
    if (arg.connectors != null) {
      connectorControllers.addAll(arg.connectors!.map((c) =>
        ConnectorControllers(type: c.type, quantity: c.quantity.toString())));
    }
    if (arg.ioPorts != null) {
      ioPortsControllers.addAll(arg.ioPorts!.map((p) =>
        IOPortControllers(port: p.port, quantity: p.quantity.toString())));
    }
    if (arg.pcieSlots != null) {
      pcieSlotsController.addAll(arg.pcieSlots!.map((s) =>
        PCIeSlotControllers(
          physicalSize: s.physicalSize.toString(),
          electricalSpeed: s.electricalSpeed.toString(),
          gen: s.gen.toString(),
          quantity: s.quantity.toString()
        )));
    }
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
    releaseDateController.dispose();

    busController.dispose();
    typeController.dispose();
    stickCountController.dispose();
    clLatencyController.dispose();
    capacityController.dispose();

    cpuSeriesController.dispose();
    socketController.dispose();
    coreController.dispose();
    threadController.dispose();
    baseClockController.dispose();
    turboClockController.dispose();
    tdpController.dispose();

    maxWattageController.dispose();
    efficiencyController.dispose();
    modularityController.dispose();

    gpuSeriesController.dispose();
    gpuVersionController.dispose();

    mainboardFormFactorController.dispose();
    chipsetCodeController.dispose();
    storageSlotControllerSingle?.m2SlotsController.dispose();
    storageSlotControllerSingle?.sataPortsController.dispose();
    formFactorController.dispose();

    genController.dispose();
    interfaceTypeController.dispose();
    writeMbpsController.dispose();
    readMbpsController.dispose();
    driveTypeController.dispose();
    driveFormFactorController.dispose();

    for (var c in connectorControllers) {
      c.typeController.dispose();
      c.quantityController.dispose();
    }
    for (var c in ioPortsControllers) {
      c.portController.dispose();
      c.quantityController.dispose();
    }
    for (var c in pcieSlotsController) {
      c.physicalSizeController.dispose();
      c.electricalSpeedController.dispose();
      c.genController.dispose();
      c.quantityController.dispose();
    }
    super.dispose();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocConsumer<AddProductCubit, AddProductState>(
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
              content: state.notifyMessage.getLocalizedMessage(context, state.exceptionError),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        }
        },
        builder: (context, state) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isMobile = screenWidth < 500;

          return Container(
            width: isMobile ? screenWidth : screenWidth * 0.9,
            height: isMobile ? screenHeight : screenHeight * 0.95,
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 1400,
              maxHeight: isMobile ? double.infinity : 1000,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  isMobile ? BorderRadius.zero : BorderRadius.circular(16),
              boxShadow: isMobile
                  ? null
                  : [
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
      ),
    );
  }

  Widget _buildHeader(AddProductState state) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: isMobile
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_box,
            color: Theme.of(context).colorScheme.primary,
            size: isMobile ? 24 : 28,
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 4),
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
                _buildCategorySpecificationsSection(state),
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
                        S.of(context).clickToManageImages,
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
                        S.of(context).manage,
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
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                Expanded(
                  child: Text(
                    S.of(context).basicInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
            if (isMobile) ...[
              // Mobile: Stack vertically
              buildInputWidget<int>(
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
              const SizedBox(height: 16),
              buildInputWidget<int>(
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
              const SizedBox(height: 16),
              buildInputWidget<String>(
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
                      currentArg.copyWith(discount: parsed?.toInt()));
                },
                null,
              ),
              const SizedBox(height: 16),
              buildInputWidget<int>(
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
            ] else ...[
              // Desktop: Side by side
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
                            currentArg.copyWith(discount: parsed?.toInt()));
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
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInformationSection(AddProductState state) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                Expanded(
                  child: Text(
                    S.of(context).additionalInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                Flexible(
                  child: Text(
                    '${S.of(context).categorySpecifications} ${state.productArgument?.category.toString()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 16),
            MultiFieldWithIcon(
              controller: enDescriptionController,
              hintText: S.of(context).enterField(S.of(context).enDescription),
              labelText: S.of(context).enDescription,
              onChanged: (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(enDescription: value));
              },
              suffixIcon: (state.productArgument?.isEnEmpty ?? true) &&
                      (state.productArgument?.isViEmpty ?? true)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () => cubit.generateEnDescription(),
            ),
            const SizedBox(height: 16),
            MultiFieldWithIcon(
              controller: viDescriptionController,
              hintText: S.of(context).enterField(S.of(context).viDescription),
              labelText: S.of(context).viDescription,
              onChanged: (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(viDescription: value));
              },
              suffixIcon: (state.productArgument?.isEnEmpty ?? true) &&
                      (state.productArgument?.isViEmpty ?? true)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () => cubit.generateViDescription(),
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
          buildInputWidget<RAMType>(S.of(context).ramType,
              typeController, state.productArgument?.type, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(type: value));
          }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).ramBus,
            busController,
            state.productArgument?.bus,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(bus: value)),
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).capacityPerStick,
            capacityController,
            state.productArgument?.capacity,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(capacity: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).kitStickCount,
            stickCountController,
            state.productArgument?.stickCount,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(stickCount: value)),
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).clLatency,
            clLatencyController,
            state.productArgument?.clLatency,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(clLatency: value)),
          ),
        ]);

      case CategoryEnum.cpu:
        return Column(key: const ValueKey('cpu_fields'), children: [
          buildInputWidget<CPUSeries>(
              S.of(context).cpuSeries,
              cpuSeriesController,
              state.productArgument?.cpuSeries, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(cpuSeries: value));
          }, CPUSeries.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).numberOfCpuCores,
            coreController,
            state.productArgument?.core,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(core: value))),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).numberOfCpuThreads,
            threadController,
            state.productArgument?.thread,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(thread: value))),
          const SizedBox(height: 8),
          buildInputWidget<double>(S.of(context).cpuBaseClock,
            baseClockController,
            state.productArgument?.baseClock,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(baseClock: value)),
            null, // Removed suffix text manually passed, handled by widget logic if needed but mostly handled inside buildInputWidget now
          ),
          const SizedBox(height: 8),
          buildInputWidget<double>(S.of(context).cpuTurboClock,
            turboClockController,
            state.productArgument?.turboClock,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(turboClock: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).cpuTdp,
            tdpController,
            state.productArgument?.tdp,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(tdp: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<Socket>(S.of(context).cpuSocket,
              socketController, state.productArgument?.socket, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(socket: value));
          }, Socket.getValues()),
        ]);

      case CategoryEnum.psu:
        return Column(key: const ValueKey('psu_fields'), children: [
          buildInputWidget<int>(S.of(context).maxWattage,
            maxWattageController,
            state.productArgument?.tdp,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(tdp: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<PSUEfficiency>(S.of(context).psuEfficiency,
              efficiencyController, state.productArgument?.efficiency, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(efficiency: value));
          }, PSUEfficiency.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<PSUModular>(S.of(context).psuModularity,
              modularityController, state.productArgument?.modularity, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(modularity: value));
          }, PSUModular.getValues()),
          const SizedBox(height: 8),
          ...buildConnectorFields(state, cubit),
        ]);

      case CategoryEnum.gpu:
        return Column(key: const ValueKey('gpu_fields'), children: [
          buildInputWidget<GPUSeries>(S.of(context).gpuSeries,
              gpuSeriesController, state.productArgument?.gpuSeries, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(gpuSeries: value));
          }, GPUSeries.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<GPUVersion>(S.of(context).gpuVersion,
              gpuVersionController, state.productArgument?.gpuVersion, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(gpuVersion: value));
          }, GPUVersion.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).gpuMemory,
            capacityController,
            state.productArgument?.capacity,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(capacity: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).gpuTdp,
            tdpController,
            state.productArgument?.tdp,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(tdp: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<double>(S.of(context).gpuBoostClock,
            turboClockController,
            state.productArgument?.turboClock,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(turboClock: value)),
            null,
          ),
          const SizedBox(height: 8),
          ...buildIOPortFields(state, cubit),
        ]);

      case CategoryEnum.mainboard:
        return Column(key: const ValueKey('mainboard_fields'), children: [
          buildInputWidget<String>(S.of(context).chipsetCode,
              chipsetCodeController,
              state.productArgument?.chipsetCode, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(chipsetCode: value));
          }),
          const SizedBox(height: 8),
          buildInputWidget<MainboardFormFactor>(S.of(context).mainboardFormFactor,
              mainboardFormFactorController, state.productArgument?.mainboardFormFactor, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(mainboardFormFactor: value));
          }, MainboardFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).ramBusSpeed,
            busController,
            state.productArgument?.bus,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(bus: value))),
          const SizedBox(height: 8),
          buildInputWidget<RAMType>(S.of(context).supportedRamType,
              typeController, state.productArgument?.type, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(type: value));
          }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<Socket>(S.of(context).cpuSocket,
              socketController, state.productArgument?.socket, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(socket: value));
          }, Socket.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).maximumSingleRamCapacity,
              capacityController,
              state.productArgument?.capacity, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(capacity: value));
          }, null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>('Number of RAM slots',
            stickCountController,
            state.productArgument?.stickCount,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(stickCount: value))),
          const SizedBox(height: 8),
          if (storageSlotControllerSingle != null) ...[
          buildInputWidget<int>(S.of(context).numberOfM2Slots,
            storageSlotControllerSingle!.m2SlotsController,
            state.productArgument?.storageSlot?.m2Slots,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(
                storageSlot: state.productArgument!.storageSlot?.copyWith(m2Slots: value)))),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).numberOfSataPorts,
            storageSlotControllerSingle!.sataPortsController,
            state.productArgument?.storageSlot?.sataPorts,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(
                storageSlot: state.productArgument!.storageSlot?.copyWith(sataPorts: value)))),
          ],
          const SizedBox(height: 8),
          ...buildIOPortFields(state, cubit),
          const SizedBox(height: 8),
          ...buildPCIeSlotFields(state, cubit),
        ]);

      case CategoryEnum.drive:
        return Column(key: const ValueKey('drive_fields'), children: [
          buildInputWidget<DriveGen>(S.of(context).driveGeneration,
              genController, state.productArgument?.gen, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(gen: value));
          }, DriveGen.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<DriveType>(S.of(context).driveType,
              driveTypeController, state.productArgument?.driveType, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(driveType: value));
          }, DriveType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).capacity,
            capacityController,
            state.productArgument?.capacity, (value) {
              cubit.updateProductArgument(state.productArgument!.copyWith(capacity: value));
            }, null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<InterfaceType>(S.of(context).interfaceType,
            interfaceTypeController, state.productArgument?.interfaceType, (value) {
              cubit.updateProductArgument(state.productArgument!.copyWith(interfaceType: value));
            }, InterfaceType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<DriveFormFactor>(S.of(context).driveFormFactor,
              driveFormFactorController, state.productArgument?.driveFormFactor, (value) {
            cubit.updateProductArgument(state.productArgument!.copyWith(driveFormFactor: value));
          }, DriveFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).readSpeed,
            readMbpsController,
            state.productArgument?.readMbps,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(readMbps: value)),
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(S.of(context).writeSpeed,
            writeMbpsController,
            state.productArgument?.writeMbps,
            (value) => cubit.updateProductArgument(state.productArgument!.copyWith(writeMbps: value)),
            null,
          ),
        ]);
      default:
        return Container();
    }
  }

  List<Widget> buildConnectorFields(AddProductState state, AddProductCubit cubit) {
    final connectors = state.productArgument?.connectors ?? [];
    List<Widget> widgets = connectors.asMap().entries.map<Widget>((entry) {
      final i = entry.key;
      if (i >= connectorControllers.length) connectorControllers.add(ConnectorControllers());
      return Row(
        children: [
          Expanded(child: buildInputWidget<String>(S.of(context).connectorType,
            connectorControllers[i].typeController, connectors[i].type,
            (value) => cubit.changeConnectorType(value, i))),
          const SizedBox(width: 8),
          Expanded(child: buildInputWidget<int>(S.of(context).quantity,
            connectorControllers[i].quantityController, connectors[i].quantity,
            (value) => cubit.changeConnectorQuantity(value, i))),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => setState(() {
              connectorControllers.removeAt(i);
              cubit.removeConnector(i);
            }),
          ),
        ],
      );
    }).toList();

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: Text(S.of(context).addConnector),
        onPressed: () => setState(() {
          connectorControllers.add(ConnectorControllers());
          cubit.addConnector();
        }),
      ),
    ));
    return widgets;
  }

  List<Widget> buildIOPortFields(AddProductState state, AddProductCubit cubit) {
    final ioPorts = state.productArgument?.ioPorts ?? [];
    List<Widget> widgets = ioPorts.asMap().entries.map<Widget>((entry) {
      final i = entry.key;
      if (i >= ioPortsControllers.length) ioPortsControllers.add(IOPortControllers());
      return Row(
        children: [
          Expanded(child: buildInputWidget<String>(S.of(context).port,
            ioPortsControllers[i].portController, ioPorts[i].port,
            (value) => cubit.changeIoPortType(value, i))),
          const SizedBox(width: 8),
          Expanded(child: buildInputWidget<int>(S.of(context).quantity,
            ioPortsControllers[i].quantityController, ioPorts[i].quantity,
            (value) => cubit.changeIoPortQuantity(value, i))),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => setState(() {
              ioPortsControllers.removeAt(i);
              cubit.removeIoPort(i);
            }),
          ),
        ],
      );
    }).toList();

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: Text(S.of(context).addIoPort),
        onPressed: () => setState(() {
          ioPortsControllers.add(IOPortControllers());
          cubit.addIoPort();
        }),
      ),
    ));
    return widgets;
  }

  List<Widget> buildPCIeSlotFields(AddProductState state, AddProductCubit cubit) {
    final pcieSlots = state.productArgument?.pcieSlots ?? [];
    List<Widget> widgets = pcieSlots.asMap().entries.map<Widget>((entry) {
      final i = entry.key;
      if (i >= pcieSlotsController.length) pcieSlotsController.add(PCIeSlotControllers());
      final controller = pcieSlotsController[i];
      return Row(
        children: [
          Expanded(child: buildInputWidget<int>(S.of(context).physicalSize,
            controller.physicalSizeController, pcieSlots[i].physicalSize,
            (v) => cubit.changePCIeSlotPhysicalSize(v, i))),
          const SizedBox(width: 8),
          Expanded(child: buildInputWidget<int>(S.of(context).electricalSpeed,
            controller.electricalSpeedController, pcieSlots[i].electricalSpeed,
            (v) => cubit.changePCIeSlotElectricalSpeed(v, i))),
          const SizedBox(width: 8),
          Expanded(child: buildInputWidget<int>(S.of(context).generation,
            controller.genController, pcieSlots[i].gen,
            (v) => cubit.changePCIeSlotGen(v, i))),
          const SizedBox(width: 8),
          Expanded(child: buildInputWidget<int>(S.of(context).quantity,
            controller.quantityController, pcieSlots[i].quantity,
            (v) => cubit.changePCIeSlotQuantity(v, i))),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => setState(() {
              pcieSlotsController.removeAt(i);
              cubit.removePcieSlot(i);
            }),
          ),
        ],
      );
    }).toList();

    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add),
        label: Text(S.of(context).addPcieSlot),
        onPressed: () => setState(() {
          pcieSlotsController.add(PCIeSlotControllers());
          cubit.addPcieSlot();
        }),
      ),
    ));
    return widgets;
  }

  Widget buildInputWidget<T>(
      String propertyName,
      TextEditingController controller,
      T? propertyValue,
      void Function(T?) onChanged,
      [List<T>? enumValues, String? suffixText]) {
    return Builder(builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      if (T == DateTime) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: propertyValue as DateTime? ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onChanged(picked as T?);
              },
              child: AbsorbPointer(
                child: FieldWithIcon(
                  controller: TextEditingController(
                    text: (propertyValue as DateTime?) != null
                        ? DateFormat('yyyy-MM-dd').format(propertyValue as DateTime)
                        : '',
                  ),
                  readOnly: true,
                  hintText: S.of(context).selectField(propertyName),
                  fillColor: colorScheme.surface,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        );
      } else if (enumValues != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
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
                // Remove focus from any text field
                FocusScope.of(context).unfocus();

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
        String? finalSuffixText = suffixText;

        if (T == int) {
          keyboardType = TextInputType.number;
          inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
          if (propertyName == S.of(context).importPrice ||
              propertyName == S.of(context).sellingPrice) {
            finalSuffixText = '.000đ';
          }
        } else if (T == double) {
          keyboardType = const TextInputType.numberWithOptions(decimal: true);
          inputFormatters = [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ];
          if (propertyName == S.of(context).discount) {
            finalSuffixText = '%';
            inputFormatters.add(TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;
              final double? value = double.tryParse(newValue.text);
              return (value != null && value <= 100) ? newValue : oldValue;
            }));
          }
        } else {
          keyboardType = TextInputType.text;
          inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'.*'))];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
            _FocusableFieldWithIcon(
              key: ValueKey(propertyName),
              controller: controller,
              hintText: S.of(context).enterField(propertyName),
              suffixText: finalSuffixText,
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
                    onChanged(parsed as T?);
                  }
                } else {
                  onChanged(value as T?);
                }
              },
              fillColor: colorScheme.surface,
              textColor: colorScheme.onSurface,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
            ),
          ],
        );
      }
    });
  }
}

class _FocusableFieldWithIcon extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Color fillColor;
  final Color textColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? suffixText;

  const _FocusableFieldWithIcon({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    required this.fillColor,
    required this.textColor,
    required this.keyboardType,
    required this.inputFormatters,
    this.suffixText,
  }) : super(key: key);

  @override
  State<_FocusableFieldWithIcon> createState() => _FocusableFieldWithIconState();
}

class _FocusableFieldWithIconState extends State<_FocusableFieldWithIcon> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FieldWithIcon(
      controller: widget.controller,
      focusNode: _focusNode,
      hintText: _isFocused ? '' : widget.hintText,
      onChanged: widget.onChanged,
      fillColor: widget.fillColor,
      textColor: widget.textColor,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      suffixText: widget.suffixText,
    );
  }
}


