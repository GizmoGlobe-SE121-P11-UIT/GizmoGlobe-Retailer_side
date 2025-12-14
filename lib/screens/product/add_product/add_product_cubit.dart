import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gizmoglobe_client/objects/product_related/mainboard_related/io_port.dart';
import 'package:gizmoglobe_client/objects/product_related/psu_related/connector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../objects/product_related/mainboard_related/pcie_slot.dart';
import '../../../objects/product_related/product_image.dart';
import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ImagePicker _picker = ImagePicker();
  final Firebase _firebase = Firebase();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Product? _editingProduct;

  AddProductCubit({Product? product})
      : _editingProduct = product,
        super(const AddProductState()) {
    initialize();
  }

  void initialize() {
    final editingProduct = _editingProduct;
    if (editingProduct != null) {
      // Initialize from existing product for edit mode
      final productArg = ProductArgument.fromProduct(editingProduct);
      emit(state.copyWith(
        productArgument: productArg,
      ));
      // Load existing images from subcollection
      final productId = editingProduct.productID;
      if (productId != null && productId.isNotEmpty) {
        loadProductImages(productId);
      }
    } else {
      // Provide safe defaults for basic fields. Category-specific fields remain null until user inputs them.
      emit(state.copyWith(
          productArgument: ProductArgument(
        sales: 0,
        release: DateTime.now(),
        importPrice: 0,
        sellingPrice: 0,
        discount: 0.0,
        stock: 0,
        category: CategoryEnum.cpu,
        status: ProductStatusEnum.outOfStock,
        // manufacturer left null until selected by user from UI
      )));
    }
  }

  // Existing generic update function
  void updateProductArgument(ProductArgument productArgument) {
    emit(state.copyWith(productArgument: productArgument));
  }

  // New convenience setters so UI or other code can set individual fields
  void setProductName(String name) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(productName: name));
  }

  void setImportPrice(num value) {
    final arg = state.productArgument;
    if (arg == null) return;
    // store as int when possible
    updateProductArgument(arg.copyWith(importPrice: value.toInt()));
  }

  void setSellingPrice(num value) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(sellingPrice: value.toInt()));
  }

  void setDiscount(double value) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(discount: value));
  }

  void setStock(int value) {
    final arg = state.productArgument;
    if (arg == null) return;
    // update status according to stock
    final newStatus =
        value > 0 ? ProductStatusEnum.active : ProductStatusEnum.outOfStock;
    updateProductArgument(arg.copyWith(stock: value, status: newStatus));
  }

  void setCategory(CategoryEnum category) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(category: category));
  }

  void setManufacturer(Manufacturer manufacturer) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(manufacturer: manufacturer));
  }

  void setRelease(DateTime date) {
    final arg = state.productArgument;
    if (arg == null) return;
    updateProductArgument(arg.copyWith(release: date));
  }

  List<Connector> changeConnectorType(String? type, int index) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final connectors = arg.connectors ?? [];
    if (type == null) return connectors;

    if (index < 0 || index >= connectors.length) return connectors;
    final updatedConnectors = List<Connector>.from(connectors);
    updatedConnectors[index] = updatedConnectors[index].copyWith(type: type);
    updateProductArgument(arg.copyWith(connectors: updatedConnectors));
    return updatedConnectors;
  }

  List<Connector> changeConnectorQuantity(int? quantity, int index) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final connectors = arg.connectors ?? [];
    if (index < 0 || index >= connectors.length) return connectors;
    final updatedConnectors = List<Connector>.from(connectors);
    updatedConnectors[index] =
        updatedConnectors[index].copyWith(quantity: quantity);
    updateProductArgument(arg.copyWith(connectors: updatedConnectors));
    return updatedConnectors;
  }

  List<IOPort> changeIoPortType(String? port, int index) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final ioPorts = arg.ioPorts ?? [];
    if (port == null) return ioPorts;

    if (index < 0 || index >= ioPorts.length) return ioPorts;
    final updatedIoPorts = List<IOPort>.from(ioPorts);
    updatedIoPorts[index] = updatedIoPorts[index].copyWith(port: port);
    updateProductArgument(arg.copyWith(ioPorts: updatedIoPorts));
    return updatedIoPorts;
  }

  List<IOPort> changeIoPortQuantity(int? quantity, int index) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final ioPorts = arg.ioPorts ?? [];
    if (index < 0 || index >= ioPorts.length) return ioPorts;
    final updatedIoPorts = List<IOPort>.from(ioPorts);
    updatedIoPorts[index] = updatedIoPorts[index].copyWith(quantity: quantity);
    updateProductArgument(arg.copyWith(ioPorts: updatedIoPorts));
    return updatedIoPorts;
  }

  List<PCIeSlot> changePCIeSlotPhysicalSize(int? value, int i) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final pcieSlots = arg.pcieSlots ?? [];
    if (i < 0 || i >= pcieSlots.length) return pcieSlots;

    final updatedPcieSlots = List<PCIeSlot>.from(pcieSlots);
    updatedPcieSlots[i] = updatedPcieSlots[i].copyWith(physicalSize: value);
    updateProductArgument(arg.copyWith(pcieSlots: updatedPcieSlots));
    return updatedPcieSlots;
  }

  List<PCIeSlot> changePCIeSlotElectricalSpeed(int? value, int i) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final pcieSlots = arg.pcieSlots ?? [];
    if (i < 0 || i >= pcieSlots.length) return pcieSlots;

    final updatedPcieSlots = List<PCIeSlot>.from(pcieSlots);
    updatedPcieSlots[i] = updatedPcieSlots[i].copyWith(electricalSpeed: value);
    updateProductArgument(arg.copyWith(pcieSlots: updatedPcieSlots));
    return updatedPcieSlots;
  }

  List<PCIeSlot> changePCIeSlotQuantity(int? value, int i) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final pcieSlots = arg.pcieSlots ?? [];
    if (i < 0 || i >= pcieSlots.length) return pcieSlots;

    final updatedPcieSlots = List<PCIeSlot>.from(pcieSlots);
    updatedPcieSlots[i] = updatedPcieSlots[i].copyWith(quantity: value);
    updateProductArgument(arg.copyWith(pcieSlots: updatedPcieSlots));
    return updatedPcieSlots;
  }

  List<PCIeSlot> changePCIeSlotGen(int? value, int i) {
    final arg = state.productArgument;
    if (arg == null) return [];
    final pcieSlots = arg.pcieSlots ?? [];
    if (value == null) return pcieSlots;

    if (i < 0 || i >= pcieSlots.length) return pcieSlots;
    final updatedPcieSlots = List<PCIeSlot>.from(pcieSlots);
    updatedPcieSlots[i] = updatedPcieSlots[i].copyWith(gen: value);
    updateProductArgument(arg.copyWith(pcieSlots: updatedPcieSlots));
    return updatedPcieSlots;
  }

  void toSuccess() {
    emit(state.copyWith(processState: ProcessState.success));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  /// Add image from URL with validation
  Future<void> addImageFromUrl(String url) async {
    try {
      emit(state.copyWith(isUploadingImage: true));
      // Validate URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('Invalid URL format');
      }

      // Add new image with next position
      final newPosition = state.activeImages.length;
      final newImage = ProductImage(
        url: url,
        position: newPosition,
        isNew: true,
      );

      emit(state.copyWith(
        images: [...state.images, newImage],
        isUploadingImage: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
        isUploadingImage: false,
      ));
    }
  }

  /// Add image file as pending (will be uploaded when modal is saved)
  Future<void> uploadImageFile(File imageFile) async {
    try {
      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      final String fileName = imageFile.path.split('/').last;

      // Add as pending image
      final newPosition = state.activeImages.length;
      final newImage = ProductImage.pending(
        bytes: bytes,
        fileName: fileName,
        position: newPosition,
      );

      emit(state.copyWith(
        images: [...state.images, newImage],
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error adding image file: $e');
      }
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  /// Add image bytes as pending (for web - will be uploaded when modal is saved)
  Future<void> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      // Add as pending image
      final newPosition = state.activeImages.length;
      final newImage = ProductImage.pending(
        bytes: bytes,
        fileName: fileName,
        position: newPosition,
      );

      emit(state.copyWith(
        images: [...state.images, newImage],
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error adding image bytes: $e');
      }
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  /// Load images from Firebase subcollection
  Future<void> loadProductImages(String productId) async {
    try {
      emit(state.copyWith(isLoadingImages: true));
      final images = await _firebase.getProductImagesWithDetails(productId);
      emit(state.copyWith(
        images: images,
        isLoadingImages: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading product images: $e');
      }
      emit(state.copyWith(isLoadingImages: false));
    }
  }

  /// Remove image at index (mark for deletion if existing, remove if new)
  void removeImage(int index) {
    final activeImages = state.activeImages;
    if (index < 0 || index >= activeImages.length) return;

    final imageToRemove = activeImages[index];
    final updatedImages = state.images
        .map((img) {
          if (img == imageToRemove) {
            if (img.isNew) {
              // For new images, we'll filter them out
              return null;
            } else {
              // For existing images, mark for deletion
              return img.copyWith(markedForDeletion: true);
            }
          }
          return img;
        })
        .whereType<ProductImage>()
        .toList();

    // Recalculate positions for remaining active images
    final reorderedImages = _recalculatePositions(updatedImages);
    emit(state.copyWith(images: reorderedImages));
  }

  /// Reorder images (drag and drop)
  void reorderImages(int oldIndex, int newIndex) {
    final activeImages = state.activeImages;
    if (oldIndex < 0 || oldIndex >= activeImages.length) return;
    if (newIndex < 0 || newIndex > activeImages.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final movedImage = activeImages[oldIndex];
    final reorderedActive = List<ProductImage>.from(activeImages)
      ..removeAt(oldIndex)
      ..insert(newIndex, movedImage);

    // Update positions
    final updatedActive = reorderedActive.asMap().entries.map((entry) {
      return entry.value.copyWith(position: entry.key);
    }).toList();

    // Merge back with deleted images
    final deletedImages =
        state.images.where((img) => img.markedForDeletion).toList();
    emit(state.copyWith(images: [...updatedActive, ...deletedImages]));
  }

  List<ProductImage> _recalculatePositions(List<ProductImage> images) {
    final activeImages = images.where((img) => !img.markedForDeletion).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final deletedImages = images.where((img) => img.markedForDeletion).toList();

    final reindexed = activeImages.asMap().entries.map((entry) {
      return entry.value.copyWith(position: entry.key);
    }).toList();

    return [...reindexed, ...deletedImages];
  }

  /// Save images from modal - uploads pending files and saves to subcollection
  /// This is called when user clicks the save button in the image modal
  Future<void> saveImagesFromModal() async {
    try {
      emit(state.copyWith(isUploadingImage: true));

      final productId = state.productArgument?.productID ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Process all images - upload pending ones, keep existing ones
      final List<ProductImage> processedImages = [];

      for (final image in state.images) {
        if (image.markedForDeletion) {
          // Keep deleted images for the save operation to delete them
          processedImages.add(image);
        } else if (image.hasPendingUpload) {
          // Upload pending file to Firebase Storage
          try {
            final int timestamp = DateTime.now().millisecondsSinceEpoch;
            final String extension =
                image.pendingFileName?.split('.').last ?? 'jpg';
            final String storageName = 'image_$timestamp.$extension';
            final Reference storageRef =
                _storage.ref().child('products/$productId/images/$storageName');
            final UploadTask uploadTask =
                storageRef.putData(image.pendingBytes!);
            final TaskSnapshot taskSnapshot = await uploadTask;
            final String imageUrl = await taskSnapshot.ref.getDownloadURL();

            // Replace pending image with uploaded one
            processedImages.add(ProductImage(
              url: imageUrl,
              position: image.position,
              isNew: true,
            ));
          } catch (e) {
            if (kDebugMode) {
              print('Error uploading image: $e');
            }
            // Skip failed uploads
          }
        } else {
          // Keep existing images as-is
          processedImages.add(image);
        }
      }

      // Update state with processed images
      emit(state.copyWith(
        images: processedImages,
        isUploadingImage: false,
      ));

      // Save to Firebase subcollection if we have a real product ID
      final actualProductId = state.productArgument?.productID;
      if (actualProductId != null && actualProductId.isNotEmpty) {
        await _firebase.saveProductImages(actualProductId, processedImages);
        // Reload to get document IDs
        await loadProductImages(actualProductId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving images from modal: $e');
      }
      emit(state.copyWith(
        isUploadingImage: false,
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  /// Apply local images from modal to cubit state
  /// Does NOT upload to Firebase - that happens during addProduct
  void applyLocalImages(List<ProductImage> localImages) {
    emit(state.copyWith(images: localImages));
  }

  /// Save images to Firebase - uploads pending files first, then saves to subcollection
  Future<void> saveProductImages(String productId) async {
    try {
      // Process all images - upload pending ones, keep existing ones
      final List<ProductImage> processedImages = [];

      for (final image in state.images) {
        if (image.markedForDeletion) {
          // Keep deleted images for the save operation to delete them
          processedImages.add(image);
        } else if (image.hasPendingUpload) {
          // Upload pending file to Firebase Storage
          try {
            final int timestamp = DateTime.now().millisecondsSinceEpoch;
            final String extension =
                image.pendingFileName?.split('.').last ?? 'jpg';
            final String storageName = 'image_$timestamp.$extension';
            final Reference storageRef =
                _storage.ref().child('products/$productId/images/$storageName');
            final UploadTask uploadTask =
                storageRef.putData(image.pendingBytes!);
            final TaskSnapshot taskSnapshot = await uploadTask;
            final String imageUrl = await taskSnapshot.ref.getDownloadURL();

            // Replace pending image with uploaded one
            processedImages.add(ProductImage(
              url: imageUrl,
              position: image.position,
              isNew: true,
            ));
          } catch (e) {
            if (kDebugMode) {
              print('Error uploading image: $e');
            }
            // Skip failed uploads
          }
        } else {
          // Keep existing images as-is
          processedImages.add(image);
        }
      }

      // Update state with processed images (now with URLs)
      emit(state.copyWith(images: processedImages));

      // Save to Firebase subcollection
      await _firebase.saveProductImages(productId, processedImages);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving product images: $e');
      }
      rethrow;
    }
  }

  // Legacy methods for backwards compatibility
  Future<void> pickImageFromUrl(String url) async {
    await addImageFromUrl(url);
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await uploadImageFile(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await uploadImageFile(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  Future<void> addProduct() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      final arg = state.productArgument;
      if (arg == null) {
        emit(state.copyWith(
            processState: ProcessState.failure,
            dialogName: DialogName.failure,
            notifyMessage: NotifyMessage.msg14));
        return;
      }

      // Basic validation helper that tolerates numbers stored as different numeric types
      num? toNum(dynamic v) {
        if (v == null) return null;
        if (v is num) return v;
        return double.tryParse(v.toString());
      }

      bool fail(String reason) {
        if (kDebugMode) print('AddProduct validation failed: $reason');
        emit(state.copyWith(
            processState: ProcessState.failure,
            dialogName: DialogName.failure,
            notifyMessage: NotifyMessage.msg14));
        return true;
      }

      // General required fields
      if (arg.productName == null || arg.productName!.trim().isEmpty) {
        if (fail('productName missing')) return;
      }
      final importP = toNum(arg.importPrice);
      final sellP = toNum(arg.sellingPrice);
      if (importP == null || importP <= 0) {
        if (fail('import price invalid')) return;
      }
      if (sellP == null || sellP <= 0) {
        if (fail('selling price invalid')) return;
      }
      if (arg.manufacturer == null) {
        if (fail('manufacturer missing')) return;
      }
      if (arg.category == null || arg.category == CategoryEnum.empty) {
        if (fail('category missing')) return;
      }

      // Category-specific validation (mirror fields used in ProductArgument.buildProduct)
      switch (arg.category) {
        case CategoryEnum.ram:
          if (arg.type == null ||
              arg.bus == null ||
              arg.capacity == null ||
              arg.stickCount == null ||
              arg.clLatency == null) {
            if (fail('RAM required fields missing')) return;
          }
          break;
        case CategoryEnum.cpu:
          if (arg.cpuSeries == null ||
              arg.core == null ||
              arg.thread == null ||
              arg.turboClock == null ||
              arg.socket == null ||
              arg.tdp == null) {
            if (fail('CPU required fields missing')) return;
          }
          break;
        case CategoryEnum.psu:
          if (arg.tdp == null ||
              arg.efficiency == null ||
              arg.modularity == null ||
              arg.connectors == null) {
            if (fail('PSU required fields missing')) return;
          }
          break;
        case CategoryEnum.gpu:
          if (arg.gpuSeries == null ||
              arg.gpuVersion == null ||
              arg.capacity == null ||
              arg.tdp == null ||
              arg.ioPorts == null ||
              arg.turboClock == null) {
            if (fail('GPU required fields missing')) return;
          }
          break;
        case CategoryEnum.mainboard:
          if (arg.chipsetCode == null ||
              arg.socket == null ||
              arg.mainboardFormFactor == null ||
              arg.pcieSlots == null ||
              arg.storageSlot == null ||
              arg.type == null ||
              arg.capacity == null ||
              arg.stickCount == null) {
            if (fail('Mainboard required fields missing')) return;
          }
          break;
        case CategoryEnum.drive:
          if (arg.driveType == null ||
              arg.capacity == null ||
              arg.gen == null ||
              arg.interfaceType == null ||
              arg.readMbps == null ||
              arg.writeMbps == null ||
              arg.driveFormFactor == null) {
            if (fail('Drive required fields missing')) return;
          }
          break;
        default:
          if (fail('Invalid category')) return;
      }

      // All validations passed — build product (buildProduct will still throw if something unexpected)
      Product product = arg.buildProduct();

      // imageUrl no longer written - images stored in subcollection

      // Use updateProduct if editing, addProduct if creating new
      if (_editingProduct != null) {
        await _firebase.updateProduct(product);
        // Save images to subcollection
        final productId = product.productID;
        if (productId != null && productId.isNotEmpty) {
          await saveProductImages(productId);
        }
      } else {
        await _firebase.addProduct(product);
        // Save images to subcollection
        final productId = product.productID;
        if (productId != null && productId.isNotEmpty) {
          await saveProductImages(productId);
        }
      }

      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg13));
    } catch (e, st) {
      if (kDebugMode) {
        print('Error in addProduct: $e\n$st');
      }
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg14));
    }
  }

  Future<void> generateEnDescription() async {
    if (state.productArgument!.isEnEmpty) {
      String enDescription = '';
      String viDescription = '';
      if (!state.productArgument!.isViEmpty) {
        enDescription = await translateIntoEnglish(
          state.productArgument?.viDescription ?? '',
        );

        updateProductArgument(
            state.productArgument!.copyWith(enDescription: enDescription));
      } else {
        enDescription = await generateDescription(state.productArgument!);
        viDescription = await translateIntoVietnamese(enDescription);

        updateProductArgument(state.productArgument!.copyWith(
            enDescription: enDescription, viDescription: viDescription));
      }

      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg21));
    }
  }

  Future<void> generateViDescription() async {
    if (state.productArgument!.isViEmpty) {
      String enDescription = '';
      String viDescription = '';
      if (!state.productArgument!.isEnEmpty) {
        viDescription = await translateIntoVietnamese(
          state.productArgument?.enDescription ?? '',
        );

        updateProductArgument(
            state.productArgument!.copyWith(viDescription: viDescription));
      } else {
        enDescription = await generateDescription(state.productArgument!);
        viDescription = await translateIntoVietnamese(enDescription);

        updateProductArgument(state.productArgument!.copyWith(
            enDescription: enDescription, viDescription: viDescription));
      }

      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg21));
    }
  }
}

Future<String> translateIntoEnglish(String inputText) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Translate this Vietnamese text to English changing special character like ₫ or %. Return only the translated text: $inputText'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'maxOutputTokens': 100
        }
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return inputText;
  } catch (e) {
    if (kDebugMode) {
      print('Error translating to English: $e');
    }
    return inputText;
  }
}

Future<String> translateIntoVietnamese(String inputText) async {
  try {
    if (inputText.isEmpty) {
      return '';
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'INSTRUCTION: Translate the following English text to Vietnamese without changing special character like ₫ or %.\n\nENGLISH TEXT: $inputText\n\nTRANSLATION (in Vietnamese only, no English explanation or notes):'
              }
            ]
          }
        ],
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return inputText;
  } catch (e) {
    if (kDebugMode) {
      print('Error translating to Vietnamese: $e');
    }
    return inputText;
  }
}

Future<String> generateDescription(ProductArgument inputProduct) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final productInfo = inputProduct;
    final promptDetails = [
      'Product Name: ${productInfo.productName}',
      'Category: ${productInfo.category}',
      'Manufacturer: ${productInfo.manufacturer?.manufacturerName ?? "Unknown"}',
      if (productInfo.category == CategoryEnum.ram)
        {
          'RAM type: ${productInfo.type?.toString() ?? "Unknown"}',
          'RAM bus: ${productInfo.bus ?? 0} MHz',
          'RAM capacity: ${productInfo.capacity ?? 0} GB',
          'Number of sticks: ${productInfo.stickCount ?? 0}',
        }
      else if (productInfo.category == CategoryEnum.cpu)
        {
          'CPU series: ${productInfo.cpuSeries?.toString() ?? "Unknown"}',
          'Cores: ${productInfo.core ?? 0}',
          'Threads: ${productInfo.thread ?? 0}',
          'Base clock: ${productInfo.baseClock ?? 0} GHz',
          'Turbo clock: ${productInfo.turboClock ?? 0} GHz',
          'Socket: ${productInfo.socket?.toString() ?? "Unknown"}',
          'TDP: ${productInfo.tdp ?? 0} W',
        }
      else if (productInfo.category == CategoryEnum.psu)
        {
          'PSU wattage: ${productInfo.tdp ?? 0} W',
          'PSU efficiency: ${productInfo.efficiency?.toString() ?? "Unknown"}',
          'PSU modularity: ${productInfo.modularity?.toString() ?? "Unknown"}',
          'PSU connectors: ${productInfo.connectors?.map((c) => c.toString()).join(', ') ?? "None"}',
        }
      else if (productInfo.category == CategoryEnum.gpu)
        {
          'GPU series: ${productInfo.gpuSeries?.toString() ?? "Unknown"}',
          'GPU version: ${productInfo.gpuVersion?.toString() ?? "Unknown"}',
          'GPU capacity: ${productInfo.capacity ?? 0} GB',
          'GPU boost clock: ${productInfo.turboClock ?? 0} MHz',
          'GPU TDP: ${productInfo.tdp ?? 0} W',
          'GPU I/O ports: ${productInfo.ioPorts?.map((p) => p.toString()).join(', ') ?? "None"}',
        }
      else if (productInfo.category == CategoryEnum.mainboard)
        {
          'Chipset code: ${productInfo.chipsetCode ?? "Unknown"}',
          'Socket: ${productInfo.socket?.toString() ?? "Unknown"}',
          'Form factor: ${productInfo.mainboardFormFactor?.toString() ?? "Unknown"}',
          'RAM type: ${productInfo.type?.toString() ?? "Unknown"}',
          'RAM capacity: ${productInfo.capacity ?? 0} GB',
          'Number of RAM sticks: ${productInfo.stickCount ?? 0}',
          'Storage slots: ${productInfo.storageSlot?.toString() ?? "None"}',
          'PCIe slots: ${productInfo.pcieSlots?.map((s) => s.toString()).join(', ') ?? "None"}',
          'I/O ports: ${productInfo.ioPorts?.map((p) => p.toString()).join(', ') ?? "None"}',
        }
      else if (productInfo.category == CategoryEnum.drive)
        {
          'Drive type: ${productInfo.driveType?.toString() ?? "Unknown"}',
          'Generation: ${productInfo.gen?.toString() ?? "Unknown"}',
          'Capacity: ${productInfo.capacity ?? 0} GB',
          'Interface: ${productInfo.interfaceType?.toString() ?? "Unknown"}',
          'Form factor: ${productInfo.driveFormFactor?.toString() ?? "Unknown"}',
          'Read speed: ${productInfo.readMbps ?? 0} MB/s',
          'Write speed: ${productInfo.writeMbps ?? 0} MB/s',
        }
    ].join('\n');
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Create a detailed yet concise product description in English (3-5 sentences) based on these specifications:\n$promptDetails\n\nInclude: (1) what the product is, (2) its key technical specifications, (3) its main benefits or use cases, and (4) one standout feature. Balance technical details with consumer benefits. Use professional, marketing-oriented language that highlights value. Return ONLY the description, no additional text.'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topP': 0.8,
          'maxOutputTokens': 100
        }
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        if (parts.isNotEmpty) {
          final translatedText = parts[0]['text'] as String;
          return translatedText.trim();
        }
      }
    }

    return '';
  } catch (e) {
    if (kDebugMode) {
      print('Error generating description: $e');
    }
    return '';
  }
}
