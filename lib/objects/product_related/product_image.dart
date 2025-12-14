import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Represents an image associated with a product.
/// Stored in the `products/{productID}/images` subcollection in Firebase.
class ProductImage extends Equatable {
  /// Firebase document ID (null for new images not yet saved)
  final String? id;

  /// URL of the image (either Firebase Storage URL or external URL)
  /// Empty string for pending file uploads until uploaded
  final String url;

  /// Position for ordering images (0-indexed)
  final int position;

  /// Whether this is a newly added image not yet saved to Firebase
  final bool isNew;

  /// Whether this image should be deleted on save
  final bool markedForDeletion;

  /// Pending file bytes for upload (web/mobile)
  /// Null if already uploaded or is a URL-based image
  final Uint8List? pendingBytes;

  /// Pending file name for upload
  final String? pendingFileName;

  /// Whether this image has pending file data to upload
  bool get hasPendingUpload => pendingBytes != null;

  /// Display URL - returns empty for pending uploads
  String get displayUrl => url.isNotEmpty ? url : '';

  const ProductImage({
    this.id,
    required this.url,
    required this.position,
    this.isNew = false,
    this.markedForDeletion = false,
    this.pendingBytes,
    this.pendingFileName,
  });

  /// Create a pending image from file bytes (not yet uploaded)
  factory ProductImage.pending({
    required Uint8List bytes,
    required String fileName,
    required int position,
  }) {
    return ProductImage(
      url: '', // Empty until uploaded
      position: position,
      isNew: true,
      pendingBytes: bytes,
      pendingFileName: fileName,
    );
  }

  /// Create from Firebase document data
  factory ProductImage.fromMap(String docId, Map<String, dynamic> data) {
    return ProductImage(
      id: docId,
      url: data['url'] as String? ?? '',
      position: (data['position'] as num?)?.toInt() ?? 0,
      isNew: false,
      markedForDeletion: false,
    );
  }

  /// Convert to Firebase document data
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'position': position,
    };
  }

  /// Create a copy with updated fields
  ProductImage copyWith({
    String? id,
    String? url,
    int? position,
    bool? isNew,
    bool? markedForDeletion,
    Uint8List? pendingBytes,
    String? pendingFileName,
  }) {
    return ProductImage(
      id: id ?? this.id,
      url: url ?? this.url,
      position: position ?? this.position,
      isNew: isNew ?? this.isNew,
      markedForDeletion: markedForDeletion ?? this.markedForDeletion,
      pendingBytes: pendingBytes ?? this.pendingBytes,
      pendingFileName: pendingFileName ?? this.pendingFileName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        position,
        isNew,
        markedForDeletion,
        pendingBytes,
        pendingFileName
      ];
}
