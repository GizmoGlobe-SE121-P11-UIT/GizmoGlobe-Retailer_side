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
import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ImagePicker _picker = ImagePicker();
  final Firebase _firebase = Firebase();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AddProductCubit() : super(const AddProductState()) {
    initialize();
  }

  void initialize() {
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

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _uploadImage(File(image.path));
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
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
      ));
    }
  }

  Future<void> pickImageFromUrl(String url) async {
    try {
      emit(state.copyWith(isUploadingImage: true));
      // Validate URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('Invalid URL format');
      }

      // Store the URL directly in state
      emit(state.copyWith(
        imageUrl: url,
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

  Future<void> _uploadImage(File imageFile) async {
    try {
      emit(state.copyWith(isUploadingImage: true));
      // Get product ID (if available)
      final productId = state.productArgument?.productID ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = imageFile.path.split('.').last;
      final String fileName = 'image$fileExtension';
      final Reference storageRef =
          _storage.ref().child('products/$productId/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String imageUrl = await taskSnapshot.ref.getDownloadURL();
      emit(state.copyWith(
        imageUrl: imageUrl,
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

      // Add imageUrl if present
      if (state.imageUrl != null) {
        product.imageUrl = state.imageUrl;
      }

      await _firebase.addProduct(product);

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
      'Manufacturer: ${productInfo.manufacturer}',
      if (productInfo.category == CategoryEnum.ram)
        {
          'RAM type: ${productInfo.type.toString()}',
          'RAM bus: ${productInfo.bus} MHz',
          'RAM capacity: ${productInfo.capacity} GB',
          'Number of sticks: ${productInfo.stickCount}',
        }
      else if (productInfo.category == CategoryEnum.cpu)
        {
          'CPU series: ${productInfo.cpuSeries}',
          'Cores: ${productInfo.core}',
          'Threads: ${productInfo.thread}',
          'Base clock: ${productInfo.baseClock} GHz',
          'Turbo clock: ${productInfo.turboClock} GHz',
          'Socket: ${productInfo.socket}',
          'TDP: ${productInfo.tdp} W',
        }
      else if (productInfo.category == CategoryEnum.psu)
        {
          'PSU wattage: ${productInfo.tdp} W',
          'PSU efficiency: ${productInfo.efficiency}',
          'PSU modularity: ${productInfo.modularity}',
          'PSU connectors: ${productInfo.connectors!.join(', ')}',
        }
      else if (productInfo.category == CategoryEnum.gpu)
        {
          'GPU series: ${productInfo.gpuSeries}',
          'GPU version: ${productInfo.gpuVersion}',
          'GPU capacity: ${productInfo.capacity} GB',
          'GPU boost clock: ${productInfo.turboClock} MHz',
          'GPU TDP: ${productInfo.tdp} W',
          'GPU I/O ports: ${productInfo.ioPorts!.join(', ')}',
        }
      else if (productInfo.category == CategoryEnum.mainboard)
        {
          'Chipset code: ${productInfo.chipsetCode}',
          'Socket: ${productInfo.socket}',
          'Form factor: ${productInfo.mainboardFormFactor}',
          'RAM type: ${productInfo.type}',
          'RAM capacity: ${productInfo.capacity} GB',
          'Number of RAM sticks: ${productInfo.stickCount}',
          'Storage slots: ${productInfo.storageSlot}',
          'PCIe slots: ${productInfo.pcieSlots!.join(', ')}',
          'I/O ports: ${productInfo.ioPorts!.join(', ')}',
        }
      else if (productInfo.category == CategoryEnum.drive)
        {
          'Drive type: ${productInfo.driveType}',
          'Generation: ${productInfo.gen}',
          'Capacity: ${productInfo.capacity} GB',
          'Interface: ${productInfo.interfaceType}',
          'Form factor: ${productInfo.driveFormFactor}',
          'Read speed: ${productInfo.readMbps} MB/s',
          'Write speed: ${productInfo.writeMbps} MB/s',
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
