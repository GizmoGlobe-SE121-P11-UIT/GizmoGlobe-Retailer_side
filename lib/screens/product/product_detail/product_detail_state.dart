import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';

import '../../../objects/invoice_related/rating.dart';

class ProductDetailState extends Equatable {
  final Product product;
  final Map<String, String> technicalSpecs;
  final List<String> imageUrls;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;

  final List<Rating> ratings;
  final double averageRating;
  final int totalRatingsCount;
  final bool hasMoreRatings;

  const ProductDetailState({
    required this.product,
    this.technicalSpecs = const {},
    this.imageUrls = const [],
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
    this.ratings = const [],
    this.averageRating = 0.0,
    this.totalRatingsCount = 0,
    this.hasMoreRatings = false,
  });

  @override
  List<Object?> get props => [
        product,
        technicalSpecs,
        processState,
        dialogName,
        notifyMessage,
        ratings,
        averageRating,
        totalRatingsCount,
        hasMoreRatings,
      ];

  ProductDetailState copyWith({
    Product? product,
    Map<String, String>? technicalSpecs,
    List<String>? imageUrls,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
    List<Rating>? ratings,
    double? averageRating,
    int? totalRatingsCount,
    bool? hasMoreRatings,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      imageUrls: imageUrls ?? this.imageUrls,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
      ratings: ratings ?? this.ratings,
      averageRating: averageRating ?? this.averageRating,
      totalRatingsCount: totalRatingsCount ?? this.totalRatingsCount,
      hasMoreRatings: hasMoreRatings ?? this.hasMoreRatings,
    );
  }
}
