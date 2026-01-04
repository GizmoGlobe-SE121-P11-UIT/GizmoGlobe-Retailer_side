import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/product_related/product_image.dart';
import 'package:gizmoglobe_client/screens/product/add_product/add_product_cubit.dart';
import 'dart:io';

/// Image manager for product images.
/// Uses local state - changes only apply to cubit when Save is clicked.
/// Opens as full-screen page on mobile, dialog on web/desktop.
class ImageManagerModal extends StatefulWidget {
  const ImageManagerModal({super.key});

  static Future<void> show(BuildContext context) async {
    // Get the cubit from the parent context before opening
    final cubit = context.read<AddProductCubit>();

    if (kIsWeb) {
      // On web: show as dialog
      await showDialog(
        context: context,
        builder: (dialogContext) => BlocProvider<AddProductCubit>.value(
          value: cubit,
          child: const ImageManagerModal(),
        ),
      );
    } else {
      // On mobile: push as full screen page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (routeContext) => BlocProvider<AddProductCubit>.value(
            value: cubit,
            child: const ImageManagerModal(),
          ),
        ),
      );
    }
  }

  @override
  State<ImageManagerModal> createState() => _ImageManagerModalState();
}

class _ImageManagerModalState extends State<ImageManagerModal> {
  final TextEditingController _urlController = TextEditingController();
  String? _previewUrl;
  bool _isPreviewValid = false;

  // Local state - copy of images that won't affect parent until save
  late List<ProductImage> _localImages;
  bool _initialized = false;

  AddProductCubit get cubit => context.read<AddProductCubit>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Initialize local images from cubit state (deep copy)
      _localImages = cubit.state.images.map((img) => img.copyWith()).toList();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Get active (non-deleted) images sorted by position
  List<ProductImage> get _activeImages =>
      _localImages.where((img) => !img.markedForDeletion).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

  /// Add image file locally
  Future<void> _pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes;
        String fileName = file.name;

        if (kIsWeb) {
          bytes = file.bytes;
        } else {
          if (file.path != null) {
            bytes = await File(file.path!).readAsBytes();
          }
        }

        if (bytes != null) {
          final newPosition = _activeImages.length + 1;
          final newImage = ProductImage.pending(
            bytes: bytes,
            fileName: fileName,
            position: newPosition,
          );

          setState(() {
            _localImages.add(newImage);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }

  /// Add image from URL locally
  void _addImageFromUrl(String url) {
    final newPosition = _activeImages.length + 1;
    final newImage = ProductImage(
      url: url,
      position: newPosition,
      isNew: true,
    );

    setState(() {
      _localImages.add(newImage);
    });
  }

  /// Remove image locally
  void _removeImage(int index) {
    final activeImages = _activeImages;
    if (index < 0 || index >= activeImages.length) return;

    final imageToRemove = activeImages[index];

    setState(() {
      _localImages = _localImages
          .map((img) {
            if (img == imageToRemove) {
              if (img.isNew || img.hasPendingUpload) {
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

      // Recalculate positions
      _recalculatePositions();
    });
  }

  /// Reorder images locally
  void _reorderImages(int oldIndex, int newIndex) {
    final activeImages = _activeImages;
    if (oldIndex < 0 || oldIndex >= activeImages.length) return;
    if (newIndex < 0 || newIndex > activeImages.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final movedImage = activeImages[oldIndex];
      final reorderedActive = List<ProductImage>.from(activeImages)
        ..removeAt(oldIndex)
        ..insert(newIndex, movedImage);

      // Update positions (1-indexed)
      final updatedActive = reorderedActive.asMap().entries.map((entry) {
        return entry.value.copyWith(position: entry.key + 1);
      }).toList();

      // Merge back with deleted images
      final deletedImages =
          _localImages.where((img) => img.markedForDeletion).toList();
      _localImages = [...updatedActive, ...deletedImages];
    });
  }

  void _recalculatePositions() {
    final activeImages = _localImages
        .where((img) => !img.markedForDeletion)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final deletedImages =
        _localImages.where((img) => img.markedForDeletion).toList();

    final reindexed = activeImages.asMap().entries.map((entry) {
      return entry.value.copyWith(position: entry.key + 1);
    }).toList();

    _localImages = [...reindexed, ...deletedImages];
  }

  /// Save local changes to cubit (just updates cubit state, no Firebase upload)
  void _saveChanges() {
    // Apply local images to cubit state
    cubit.applyLocalImages(_localImages);
    Navigator.pop(context);
  }

  void _showUrlInputDialog() {
    _urlController.clear();
    _previewUrl = null;
    _isPreviewValid = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.of(context).enterImageUrl),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/image.jpg',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.preview),
                          tooltip: 'Preview',
                          onPressed: () {
                            final url = _urlController.text.trim();
                            if (url.isNotEmpty) {
                              setDialogState(() {
                                _previewUrl = url;
                                _isPreviewValid = false;
                              });
                            }
                          },
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      onSubmitted: (_) {
                        final url = _urlController.text.trim();
                        if (url.isNotEmpty) {
                          setDialogState(() {
                            _previewUrl = url;
                            _isPreviewValid = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Preview area
                    if (_previewUrl != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Image.network(
                                _previewUrl!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setDialogState(() {
                                        _isPreviewValid = true;
                                      });
                                    });
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stack) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    setDialogState(() {
                                      _isPreviewValid = false;
                                    });
                                  });
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Invalid image URL',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (_isPreviewValid)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check,
                                            size: 16, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Valid',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter URL and click preview',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: _isPreviewValid
                      ? () {
                          _addImageFromUrl(_previewUrl!);
                          Navigator.pop(dialogContext);
                        }
                      : null,
                  child: Text(S.of(context).confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int index) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).confirmation),
        content: const Text('Are you sure you want to remove this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            onPressed: () {
              _removeImage(index);
              Navigator.pop(dialogContext);
            },
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = _activeImages;

    // Shared content widget
    final content = Column(
      children: [
        // Add buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Image'),
                  onPressed: _pickImageFile,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.link),
                  label: const Text('Add URL'),
                  onPressed: _showUrlInputDialog,
                ),
              ),
            ],
          ),
        ),

        // Image list
        Expanded(
          child: images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No images added yet',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload images or add URLs above',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: images.length,
                  onReorder: _reorderImages,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return _buildImageTile(image, index);
                  },
                ),
        ),
      ],
    );

    // Mobile: Full screen Scaffold
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Product Images'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save changes',
              onPressed: _saveChanges,
            ),
          ],
        ),
        body: content,
      );
    }

    // Web: Dialog
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Manage Product Images',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  // Save button
                  IconButton(
                    icon: Icon(Icons.check, color: colorScheme.primary),
                    tooltip: 'Save changes',
                    onPressed: _saveChanges,
                  ),
                  const SizedBox(width: 8),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close without saving',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(ProductImage image, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: ValueKey('${image.url}_${image.pendingFileName}_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.hasPendingUpload
                ? Image.memory(
                    image.pendingBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.error,
                      ),
                    ),
                  )
                : Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: index == 0
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                index == 0 ? 'Primary' : '#${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: index == 0
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (image.isNew || image.hasPendingUpload) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: image.hasPendingUpload
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  image.hasPendingUpload ? 'Pending' : 'New',
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        image.hasPendingUpload ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          image.hasPendingUpload
              ? (image.pendingFileName ?? 'Pending upload')
              : image.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: () => _confirmDelete(index),
              tooltip: 'Delete',
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
      ),
    );
  }
}
