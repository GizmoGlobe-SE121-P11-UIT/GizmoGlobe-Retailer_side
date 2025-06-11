import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import 'add_product_state.dart';


class AddProductCubit extends Cubit<AddProductState> {
  final ImagePicker _picker = ImagePicker();
  final Firebase _firebase = Firebase();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AddProductCubit() : super(const AddProductState()) {
    initialize();
  }

  void initialize() {
    emit(state.copyWith(
        productArgument: ProductArgument(sales: 0, release: DateTime.now())));
  }

  void updateProductArgument(ProductArgument productArgument) {
    emit(state.copyWith(productArgument: productArgument));
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
      final String fileExtension = path.extension(imageFile.path);
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
      Product product = state.productArgument!.buildProduct();
      // Add image URL to product if available
      if (state.imageUrl != null) {
        product.imageUrl = state.imageUrl;
      }
      await _firebase.addProduct(product);
      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg13));
    } catch (e) {
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg14));
    }
  }

  Future<void> generateEnDescription() async {
    String enDescription = '';
    String viDescription = '';

    if (!state.productArgument!.isViEmpty) {
      enDescription = await translateIntoEnglish(
        state.productArgument?.viDescription ?? '',
      );

      updateProductArgument(state.productArgument!.copyWith(enDescription: enDescription));
    }
    else {
      enDescription = await generateDescription(state.productArgument!);
      viDescription = await translateIntoVietnamese(enDescription);

      updateProductArgument(state.productArgument!.copyWith(
          enDescription: enDescription,
          viDescription: viDescription
      ));
    }


    emit(state.copyWith(
        processState: ProcessState.success,
        dialogName: DialogName.success,
        notifyMessage: NotifyMessage.msg21));
  }

  Future<void> generateViDescription() async {
    String enDescription = '';
    String viDescription = '';

    if (!state.productArgument!.isEnEmpty) {
      viDescription = await translateIntoVietnamese(
        state.productArgument?.enDescription ?? '',
      );

      updateProductArgument(state.productArgument!.copyWith(viDescription: viDescription));
    }
    else {
      enDescription = await generateDescription(state.productArgument!);
      viDescription = await translateIntoVietnamese(enDescription);

      updateProductArgument(state.productArgument!.copyWith(
          enDescription: enDescription,
          viDescription: viDescription
      ));
    }

    emit(state.copyWith(
        processState: ProcessState.success,
        dialogName: DialogName.success,
        notifyMessage: NotifyMessage.msg21));
  }
}

Future<String> translateIntoEnglish(String inputText) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'Translate this Vietnamese text to English changing special character like \$ or %. Return only the translated text: $inputText'
          }]
        }],
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
    print('Error translating to English: $e');
    return inputText;
  }
}

Future<String> translateIntoVietnamese(String inputText) async {
  try {
    if (inputText.isEmpty) {
      return '';
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'INSTRUCTION: Translate the following English text to Vietnamese without changing special character like \$ or %.\n\nENGLISH TEXT: $inputText\n\nTRANSLATION (in Vietnamese only, no English explanation or notes):'
          }]
        }],
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
    print('Error translating to Vietnamese: $e');
    return inputText;
  }
}

Future<String> generateDescription(ProductArgument inputProduct) async {
  try {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final dio = Dio();
    final productInfo = inputProduct;
    final promptDetails = [
      'Product Name: ${productInfo.productName}',
      'Category: ${productInfo.category}',
      'Manufacturer: ${productInfo.manufacturer}',

      if (productInfo.category == CategoryEnum.ram) {
        'RAM bus: ${productInfo.ramBus} MHz',
        'RAM capacity: ${productInfo.ramCapacity} GB',
        'RAM type: ${productInfo.ramType}',
      } else if (productInfo.category ==  CategoryEnum.cpu) {
        'SSD family: ${productInfo.family}',
        'Number of cores: ${productInfo.core}',
        'Number of threads: ${productInfo.thread}',
        'Clock speed: ${productInfo.cpuClockSpeed} GHz',
      } else if (productInfo.category == CategoryEnum.psu) {
        'Wattage: ${productInfo.wattage} W',
        'Efficiency: ${productInfo.efficiency}',
        'Modular: ${productInfo.modular}',
      } else if (productInfo.category == CategoryEnum.gpu) {
        'GPU capacity: ${productInfo.gpuCapacity} GB',
        'GPU clock Speed: ${productInfo.gpuClockSpeed} MHz',
        'GPU series: ${productInfo.gpuSeries}',
        'GPU bus: ${productInfo.gpuBus} bit',
      } else if (productInfo.category == CategoryEnum.mainboard) {
        'Mainboard form factor: ${productInfo.formFactor}',
        'Mainboard series: ${productInfo.mainboardSeries}',
        'Mainboard compatibility: ${productInfo.compatibility}',
      } else if (productInfo.category == CategoryEnum.drive) {
        'Drive type: ${productInfo.driveType}',
        'Drive capacity: ${productInfo.driveCapacity} GB',
      }
    ].join('\n');
    final response = await dio.post(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'contents': [{
          'parts': [{
            'text': 'Create a detailed yet concise product description in English (3-5 sentences) based on these specifications:\n$promptDetails\n\nInclude: (1) what the product is, (2) its key technical specifications, (3) its main benefits or use cases, and (4) one standout feature. Balance technical details with consumer benefits. Use professional, marketing-oriented language that highlights value. Return ONLY the description, no additional text.'          }]
        }],
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
    print('Error generating description: $e');
    return '';
  }
}
