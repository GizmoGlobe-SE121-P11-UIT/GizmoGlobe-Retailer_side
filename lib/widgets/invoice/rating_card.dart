import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

import '../../screens/media/fullscreen_media_viewer.dart';
import '../product/product_minicard.dart';
import '../../objects/product_related/product.dart';

class RatingCard extends StatelessWidget {
  final dynamic rating;
  // Optional callback when the user taps "Reply" for ratings without a reply.
  // Provides the rating's id as argument.
  final void Function(String ratingId)? onReply;
  // Optional callback to post a reply (ratingId, comment, optional productId).
  // If provided, the RatingCard will show the reply dialog and call this to post.
  final Future<void> Function(String ratingId, String comment,
      {String? productId})? onPostReply;
  // Optional: attach a product mini card at the top of the rating card
  final bool attachProduct;
  final Product? product;

  const RatingCard(
      {super.key,
      required this.rating,
      this.onReply,
      this.onPostReply,
      this.attachProduct = false,
      this.product});

  @override
  Widget build(BuildContext context) {
    final r = rating;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attachProduct && product != null) ...[
              // make the mini card a bit narrower so it is inset from the parent card sides
              Align(
                alignment: Alignment.centerLeft,
                child: ProductMiniCard(product: product!),
              ),
              const SizedBox(height: 8),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.username ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if ((r.rating ?? 0) > 0) ...[
                    Text((r.rating as num).toDouble().toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ]
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                DateFormat('dd/MM/yyyy').format(r.timeSent),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            if (r.comment != null && (r.comment as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(r.comment),
              ),
            if ((r.videoUrl != null && (r.videoUrl as String).isNotEmpty) ||
                (r.imagesUrl != null && (r.imagesUrl as List).isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.videoUrl != null && (r.videoUrl as String).isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                FullscreenMediaViewer(videoUrl: r.videoUrl),
                          ));
                        },
                        child: Container(
                          height: 160,
                          color: Theme.of(context).colorScheme.surface,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(r.videoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox()),
                              const Center(
                                child: Icon(Icons.play_circle,
                                    color: Color.fromRGBO(255, 255, 255, 0.9),
                                    size: 56),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (r.imagesUrl != null && (r.imagesUrl as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: (r.imagesUrl as List).map<Widget>((img) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (_) =>
                                          FullscreenMediaViewer(imageUrl: img),
                                    ));
                                  },
                                  child: Image.network(img,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox()),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Reply display: if reply exists show it; else always show a Reply button
            if (r.reply != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gizmo Globe',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface)),
                    const SizedBox(height: 6),
                    Text(r.reply.comment ?? ''),
                    const SizedBox(height: 6),
                    if (r.reply.timestamp != null)
                      Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(r.reply.timestamp),
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ] else ...[
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final id = r.ratingID ?? '';
                    if (kDebugMode) {
                      print('RatingCard: Reply button pressed for id=$id');
                    }
                    // If an inline post callback is provided, open the dialog and post here
                    if (onPostReply != null) {
                      if (kDebugMode) {
                        print(
                            'RatingCard: onPostReply available, showing dialog');
                      }
                      _showReplyDialog(context, id, productId: r.productID);
                      return;
                    }
                    // Fallback: call onReply if provided (legacy behavior)
                    if (onReply != null) onReply!(id);
                  },
                  child: Text(S.of(context).reply),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext parentCtx, String ratingId,
      {String? productId}) {
    if (kDebugMode) {
      print('RatingCard: _showReplyDialog called for id=$ratingId');
    }
    final TextEditingController controller = TextEditingController();
    bool posting = false;

    if (kDebugMode) {
      print('RatingCard: showing dialog for id=$ratingId using parentCtx');
    }
    showDialog<void>(
      context: parentCtx,
      barrierDismissible: false,
      builder: (dialogCtx) {
        if (kDebugMode) print('RatingCard: building dialog for id=$ratingId');
        return StatefulBuilder(builder: (contextSB, setStateSB) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(parentCtx).reply),
                IconButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              height: 120,
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: S.of(parentCtx).writeAReply,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: posting ? null : () => Navigator.of(dialogCtx).pop(),
                child: Text(S.of(parentCtx).cancel),
              ),
              ElevatedButton(
                onPressed: posting
                    ? null
                    : () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setStateSB(() => posting = true);
                        // show a simple loading dialog while posting
                        bool loadingShown = false;
                        void showLoading() {
                          if (!loadingShown && dialogCtx.mounted) {
                            loadingShown = true;
                            showDialog<void>(
                              context: dialogCtx,
                              barrierDismissible: false,
                              builder: (_) => WillPopScope(
                                onWillPop: () async => false,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                            );
                          }
                        }

                        void hideLoading() {
                          if (loadingShown && dialogCtx.mounted) {
                            try {
                              Navigator.of(dialogCtx).pop();
                            } catch (_) {}
                            loadingShown = false;
                          }
                        }

                        showLoading();
                        try {
                          await onPostReply!(ratingId, text,
                              productId: productId);
                          hideLoading();
                          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                          if (parentCtx.mounted) {
                            SnackbarService.showSuccess(
                              parentCtx,
                              S.of(parentCtx).replyPostedSuccessfully,
                              '',
                            );
                          }
                        } catch (e) {
                          hideLoading();
                          if (parentCtx.mounted) {
                            showDialog(
                              context: parentCtx,
                              builder: (_) => InformationDialog(
                                title: S.of(parentCtx).errorOccurred,
                                content: e.toString(),
                                buttonText: S.of(parentCtx).confirm,
                              ),
                            );
                          }
                        } finally {
                          if (contextSB.mounted) {
                            setStateSB(() => posting = false);
                          }
                        }
                      },
                child: posting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(S.of(parentCtx).postReply),
              ),
            ],
          );
        });
      },
    );
  }
}
