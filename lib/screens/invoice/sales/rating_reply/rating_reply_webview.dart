import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import '../../../../objects/invoice_related/rating.dart';
import '../../../../widgets/invoice/rating_card.dart';
import '../../../../data/database/database.dart';
import '../../../../objects/product_related/product.dart';
import 'rating_reply_cubit.dart';
import 'rating_reply_state.dart';

class RatingReplyWebView extends StatefulWidget {
  const RatingReplyWebView({super.key});

  static Widget newInstance() => BlocProvider(
        create: (_) => RatingReplyCubit()..fetchRatings(),
        child: const RatingReplyWebView(),
      );

  @override
  State<RatingReplyWebView> createState() => _RatingReplyWebViewState();
}

class _RatingReplyWebViewState extends State<RatingReplyWebView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  RatingReplyCubit get cubit => context.read<RatingReplyCubit>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildList(List<Rating> list, {bool replied = false}) {
    final blocState = cubit.state;
    final hasMore = blocState is RatingReplyLoaded
        ? (replied ? blocState.hasMoreReplied : blocState.hasMoreNew)
        : false;

    if (list.isEmpty) {
      if (hasMore) {
        return Center(
          child: OutlinedButton(
            onPressed: () async {
              if (replied) {
                await cubit.loadMoreReplied();
              } else {
                await cubit.loadMoreNew();
              }
              if (mounted) setState(() {});
            },
            child: Text(S.of(context).loadMore),
          ),
        );
      }
      return Center(child: Text(S.of(context).noItems));
    }

    final itemCount = list.length + (hasMore ? 1 : 0);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= list.length) {
          return Center(
            child: OutlinedButton(
              onPressed: () async {
                if (replied) {
                  await cubit.loadMoreReplied();
                } else {
                  await cubit.loadMoreNew();
                }
                if (mounted) setState(() {});
              },
              child: Text(S.of(context).loadMore),
            ),
          );
        }
        final r = list[index];
        Product? product;
        try {
          product = Database()
              .productList
              .firstWhere((p) => p.productID == r.productID);
        } catch (_) {
          product = null;
        }

        return RatingCard(
          rating: r,
          attachProduct: product != null,
          product: product,
          onPostReply: (ratingId, comment, {productId}) async {
            await cubit.replyToRating(
                ratingId: ratingId, comment: comment, productId: productId);
            if (mounted) {
              try {
                _tabController.index = 1;
              } catch (_) {}
              setState(() {});
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rate_review,
                        color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context).ratingsAndReplies,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      color: colorScheme.primary,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor:
                    colorScheme.onSurface.withValues(alpha: 0.7),
                indicatorColor: colorScheme.primary,
                tabs: [
                  Tab(text: S.of(context).newRatings),
                  Tab(text: S.of(context).repliedRatings),
                ],
              ),

              // Body
              Expanded(
                child: BlocBuilder<RatingReplyCubit, RatingReplyState>(
                  builder: (context, state) {
                    if (state is RatingReplyLoading ||
                        state is RatingReplyInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RatingReplyLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(state.newRatings),
                          _buildList(state.repliedRatings, replied: true),
                        ],
                      );
                    } else if (state is RatingReplyError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
