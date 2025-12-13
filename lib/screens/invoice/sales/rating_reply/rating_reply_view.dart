import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../objects/invoice_related/rating.dart';
import '../../../../widgets/invoice/rating_card.dart';
import '../../../../data/database/database.dart';
import '../../../../objects/product_related/product.dart';
import 'rating_reply_cubit.dart';
import 'rating_reply_state.dart';

class RatingReplyView extends StatefulWidget {
  const RatingReplyView({super.key});

  // Keep the same factory pattern used across the app
  static Widget newInstance() => BlocProvider(
        create: (_) => RatingReplyCubit(), // don't call fetchRatings here
        // Use Builder so the subtree has a BuildContext that can read the provider immediately
        child: Builder(builder: (context) => const RatingReplyView()),
      );

  @override
  State<RatingReplyView> createState() => _RatingReplyViewState();
}

class _RatingReplyViewState extends State<RatingReplyView> {
  @override
  Widget build(BuildContext context) {
    // The actual page content is implemented in the existing private state
    return const _RatingReplyPage();
  }
}

class _RatingReplyPage extends StatefulWidget {
  const _RatingReplyPage();

  @override
  State<_RatingReplyPage> createState() => _RatingReplyPageState();
}

class _RatingReplyPageState extends State<_RatingReplyPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // If no provider is found in the widget tree, we'll create a local cubit and own it.
  RatingReplyCubit? _localCubit;
  bool _ownsCubit = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    // Listen so we can rebuild when tab changes and show/hide FAB accordingly
    _tabController.addListener(_onTabChanged);

    // Move fetchRatings here: try to use upstream provider; if none, create local cubit
    try {
      // If a provider exists above, read it and call fetch
      final cubit = context.read<RatingReplyCubit>();
      cubit.fetchRatings();
    } catch (e) {
      // No provider above us: create a local cubit and fetch
      _localCubit = RatingReplyCubit()..fetchRatings();
      _ownsCubit = true;
    }

    super.initState();
  }

  RatingReplyCubit get _effectiveCubit {
    return _localCubit ?? context.read<RatingReplyCubit>();
  }

  void _onTabChanged() {
    // Only rebuild UI when the tab index actually changed (avoid intermediate animation values)
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    if (_ownsCubit) {
      _localCubit?.close();
    }
    super.dispose();
  }

  Widget _buildList(List<Rating> list, {bool replied = false}) {
    final blocState = _effectiveCubit.state;
    final hasMore = blocState is RatingReplyLoaded ? (replied ? blocState.hasMoreReplied : blocState.hasMoreNew) : false;
    // If list is empty but server indicates there are more items, show a Load more button
    if (list.isEmpty) {
      if (hasMore) {
        return Center(
          child: OutlinedButton(
            onPressed: () async {
              if (replied) {
                await _effectiveCubit.loadMoreReplied();
              } else {
                await _effectiveCubit.loadMoreNew();
              }
              if (mounted) setState(() {});
            },
            child: const Text('Load more'),
          ),
        );
      }
      return const Center(child: Text('No items'));
    }

    final itemCount = list.length + (hasMore ? 1 : 0);
    return ListView.separated(
      // padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= list.length) {
          // Load more button
          return Center(
            child: OutlinedButton(
              onPressed: () async {
                if (replied) {
                  await _effectiveCubit.loadMoreReplied();
                } else {
                  await _effectiveCubit.loadMoreNew();
                }
                if (mounted) setState(() {});
              },
              child: const Text('Load more'),
            ),
          );
        }
        final r = list[index];
        Product? product;
        try {
          product = Database().productList.firstWhere((p) => p.productID == r.productID);
        } catch (_) {
          product = null;
        }

        return RatingCard(
          rating: r,
          attachProduct: product != null,
          product: product,
          onPostReply: (ratingId, comment, {productId}) async {
            // delegate posting to the cubit
            await _effectiveCubit.replyToRating(ratingId: ratingId, comment: comment, productId: productId);
            // after posting, refresh is handled by cubit; switch to replied tab
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Replies'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Replied'),
          ],
        ),
      ),
      body: BlocBuilder<RatingReplyCubit, RatingReplyState>(
        // Use bloc parameter so we don't depend on provider-only lookups inside BlocBuilder's initState
        bloc: _effectiveCubit,
        builder: (context, state) {
          if (state is RatingReplyLoading || state is RatingReplyInitial) {
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
      // No FAB here: InvoiceScreen is responsible for showing the FAB.
    );
  }
}
