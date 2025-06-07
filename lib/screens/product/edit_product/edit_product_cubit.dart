import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import 'edit_product_state.dart';

class EditProductCubit extends Cubit<EditProductState> {
  EditProductCubit() : super(const EditProductState());

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void initialize(Product product) {
    final productArgument = ProductArgument.fromProduct(product);
    emit(state.copyWith(
      productArgument: productArgument,
      imageUrl: product.imageUrl,
      processState: ProcessState.idle,
    ));
  }

  void updateProductArgument(ProductArgument productArgument) {
    emit(state.copyWith(productArgument: productArgument));
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
      emit(state.copyWith(isUploadingImage: false));
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(isUploadingImage: false));
    }
  }

  Future<void> pickImageFromUrl(String url) async {
    emit(state.copyWith(isUploadingImage: true));
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('Invalid URL format');
      }
      emit(state.copyWith(imageUrl: url, isUploadingImage: false));
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
    emit(state.copyWith(isUploadingImage: true));
    try {
      final productId = state.productArgument?.productID ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String fileExtension = path.extension(imageFile.path);
      final String fileName = 'image$fileExtension';
      final Reference storageRef =
          _storage.ref().child('products/$productId/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      emit(state.copyWith(imageUrl: downloadUrl, isUploadingImage: false));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        notifyMessage: NotifyMessage.msg14,
        isUploadingImage: false,
      ));
    }
  }

  Future<void> editProduct() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Product product = state.productArgument!.buildProduct();
      // Add image URL to product if available
      if (state.imageUrl != null) {
        product.imageUrl = state.imageUrl;
      }
      await Firebase().updateProduct(product);
      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg15));
    } catch (e) {
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg16));
    }
  }
}
