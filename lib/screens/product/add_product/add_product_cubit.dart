import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
}
