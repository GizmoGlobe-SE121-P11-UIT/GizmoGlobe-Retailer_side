import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';
import 'package:gizmoglobe_client/objects/product_related/product_image.dart';

class AddProductState extends Equatable {
  final ProductArgument? productArgument;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;
  final List<ProductImage> images;
  final bool isUploadingImage;
  final bool isLoadingImages;
  final String? exceptionError;

  const AddProductState({
    this.productArgument,
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
    this.images = const [],
    this.isUploadingImage = false,
    this.isLoadingImages = false,
    this.exceptionError,
  });

  /// Get the first image URL for thumbnail display (only uploaded images, not pending)
  String? get primaryImageUrl {
    final uploadedImages = activeImages
        .where((img) => !img.hasPendingUpload && img.url.isNotEmpty);
    return uploadedImages.isNotEmpty ? uploadedImages.first.url : null;
  }

  /// Get active (non-deleted) images sorted by position
  List<ProductImage> get activeImages =>
      images.where((img) => !img.markedForDeletion).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

  @override
  List<Object?> get props => [
        productArgument,
        processState,
        dialogName,
        notifyMessage,
        images,
        isUploadingImage,
        isLoadingImages,
        exceptionError,
      ];

  AddProductState copyWith({
    ProductArgument? productArgument,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
    List<ProductImage>? images,
    bool? isUploadingImage,
    bool? isLoadingImages,
    String? exceptionError,
  }) {
    return AddProductState(
      productArgument: productArgument ?? this.productArgument,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
      images: images ?? this.images,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isLoadingImages: isLoadingImages ?? this.isLoadingImages,
      exceptionError: exceptionError ?? this.exceptionError,
    );
  }
}
