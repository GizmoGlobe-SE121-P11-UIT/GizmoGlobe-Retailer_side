import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../objects/invoice_related/rating.dart';
import 'rating_reply_state.dart';
import '../../../../data/database/database.dart';
import '../../../../objects/invoice_related/reply.dart';

class RatingReplyCubit extends Cubit<RatingReplyState> {
  final FirebaseFirestore _firestore;
  static const int _pageSize = 5;

  DocumentSnapshot? _lastNewDoc;
  DocumentSnapshot? _lastRepliedDoc;
  bool _hasMoreNew = true;
  bool _hasMoreReplied = true;
  // Fallback (client-side) pagination state
  bool _usingFallback = false;
  List<Rating> _fallbackNewAll = [];
  List<Rating> _fallbackRepliedAll = [];
  int _fallbackNewIndex = 0; // next index to load from fallback
  int _fallbackRepliedIndex = 0;

  RatingReplyCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(RatingReplyInitial());

  Future<void> fetchRatings() async {
    // initial load for both lists
    emit(RatingReplyLoading());
    try {
      _lastNewDoc = null;
      _lastRepliedDoc = null;
      _hasMoreNew = true;
      _hasMoreReplied = true;

      // Fetch all ratings and filter client-side since Firestore isNull doesn't work for missing fields
      final allSnapshot = await _firestore
          .collection('order_ratings')
          .orderBy('timeSent', descending: true)
          .get();

      if (kDebugMode) {
        print('fetchRatings: fetched ${allSnapshot.docs.length} total ratings');
      }

      final List<Rating> allNewRatings = [];
      final List<Rating> allRepliedRatings = [];

      for (var doc in allSnapshot.docs) {
        try {
          final rating = Rating.fromDoc(doc);
          // Populate username if possible (best effort)
          if (rating.userID.isNotEmpty) {
            try {
              final userDoc = await _firestore
                  .collection('customers')
                  .doc(rating.userID)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName =
                    (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }

          // Client-side filtering: check if reply exists
          if (rating.reply != null) {
            allRepliedRatings.add(rating);
          } else {
            allNewRatings.add(rating);
          }
        } catch (e, st) {
          if (kDebugMode) {
            print('fetchRatings: parse doc error ${doc.id}: $e\n$st');
          }
        }
      }

      if (kDebugMode) {
        print(
            'fetchRatings: new=${allNewRatings.length}, replied=${allRepliedRatings.length}');
      }

      // Use client-side pagination
      _usingFallback = true;
      _fallbackNewAll = allNewRatings;
      _fallbackRepliedAll = allRepliedRatings;
      _fallbackNewIndex = 0;
      _fallbackRepliedIndex = 0;

      final firstNew = _fallbackNewAll.take(_pageSize).toList();
      final firstReplied = _fallbackRepliedAll.take(_pageSize).toList();
      _fallbackNewIndex = firstNew.length;
      _fallbackRepliedIndex = firstReplied.length;
      _lastNewDoc = null;
      _lastRepliedDoc = null;
      _hasMoreNew = _fallbackNewAll.length > _fallbackNewIndex;
      _hasMoreReplied = _fallbackRepliedAll.length > _fallbackRepliedIndex;

      emit(RatingReplyLoaded(
        newRatings: firstNew,
        repliedRatings: firstReplied,
        hasMoreNew: _hasMoreNew,
        hasMoreReplied: _hasMoreReplied,
      ));
    } catch (e, st) {
      if (kDebugMode) print('fetchRatings: error fetching ratings: $e\n$st');
      emit(RatingReplyError(e.toString()));
    }
  }

  Future<void> loadMoreNew() async {
    if (_usingFallback) {
      // Serve next page from fallback list
      if (!_hasMoreNew) return;
      final current = state is RatingReplyLoaded
          ? (state as RatingReplyLoaded).newRatings
          : <Rating>[];
      final nextEnd =
          (_fallbackNewIndex + _pageSize).clamp(0, _fallbackNewAll.length);
      final more = _fallbackNewAll.sublist(_fallbackNewIndex, nextEnd);
      _fallbackNewIndex = nextEnd;
      _hasMoreNew = _fallbackNewAll.length > _fallbackNewIndex;
      final updated = [...current, ...more];
      emit(RatingReplyLoaded(
          newRatings: updated,
          repliedRatings: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).repliedRatings
              : <Rating>[],
          hasMoreNew: _hasMoreNew,
          hasMoreReplied: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).hasMoreReplied
              : false));
      return;
    }

    if (!_hasMoreNew || _lastNewDoc == null) return;
    try {
      final snapshot = await _firestore
          .collection('order_ratings')
          .where('reply', isNull: true)
          .orderBy('timeSent', descending: true)
          .startAfterDocument(_lastNewDoc!)
          .limit(_pageSize)
          .get();

      final List<Rating> more = [];
      for (var doc in snapshot.docs) {
        try {
          final rating = Rating.fromDoc(doc);
          more.add(rating);
          if (rating.userID.isNotEmpty) {
            try {
              final userDoc = await _firestore
                  .collection('customers')
                  .doc(rating.userID)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName =
                    (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
      final current = state is RatingReplyLoaded
          ? (state as RatingReplyLoaded).newRatings
          : <Rating>[];
      final updated = [...current, ...more];
      _lastNewDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastNewDoc;
      _hasMoreNew = snapshot.docs.length >= _pageSize;
      emit(RatingReplyLoaded(
          newRatings: updated,
          repliedRatings: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).repliedRatings
              : <Rating>[],
          hasMoreNew: _hasMoreNew,
          hasMoreReplied: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).hasMoreReplied
              : false));
    } catch (e, st) {
      if (kDebugMode) print('loadMoreNew error: $e\n$st');
    }
  }

  Future<void> loadMoreReplied() async {
    if (_usingFallback) {
      if (!_hasMoreReplied) return;
      final current = state is RatingReplyLoaded
          ? (state as RatingReplyLoaded).repliedRatings
          : <Rating>[];
      final nextEnd = (_fallbackRepliedIndex + _pageSize)
          .clamp(0, _fallbackRepliedAll.length);
      final more = _fallbackRepliedAll.sublist(_fallbackRepliedIndex, nextEnd);
      _fallbackRepliedIndex = nextEnd;
      _hasMoreReplied = _fallbackRepliedAll.length > _fallbackRepliedIndex;
      final updated = [...current, ...more];
      emit(RatingReplyLoaded(
          newRatings: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).newRatings
              : <Rating>[],
          repliedRatings: updated,
          hasMoreNew: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).hasMoreNew
              : false,
          hasMoreReplied: _hasMoreReplied));
      return;
    }

    if (!_hasMoreReplied || _lastRepliedDoc == null) return;
    try {
      final snapshot = await _firestore
          .collection('order_ratings')
          .where('reply', isNull: false)
          .orderBy('timeSent', descending: true)
          .startAfterDocument(_lastRepliedDoc!)
          .limit(_pageSize)
          .get();

      final List<Rating> more = [];
      for (var doc in snapshot.docs) {
        try {
          final rating = Rating.fromDoc(doc);
          more.add(rating);
          if (rating.userID.isNotEmpty) {
            try {
              final userDoc = await _firestore
                  .collection('customers')
                  .doc(rating.userID)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName =
                    (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
      final current = state is RatingReplyLoaded
          ? (state as RatingReplyLoaded).repliedRatings
          : <Rating>[];
      final updated = [...current, ...more];
      _lastRepliedDoc =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastRepliedDoc;
      _hasMoreReplied = snapshot.docs.length >= _pageSize;
      emit(RatingReplyLoaded(
          newRatings: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).newRatings
              : <Rating>[],
          repliedRatings: updated,
          hasMoreNew: state is RatingReplyLoaded
              ? (state as RatingReplyLoaded).hasMoreNew
              : false,
          hasMoreReplied: _hasMoreReplied));
    } catch (e, st) {
      if (kDebugMode) print('loadMoreReplied error: $e\n$st');
    }
  }

  /// Post a reply to a rating. Constructs a `Reply` object and calls Database().replyToRating.
  Future<void> replyToRating(
      {required String ratingId,
      required String comment,
      String? productId}) async {
    try {
      final reply = Reply(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          comment: comment,
          timestamp: DateTime.now());

      // Use Database wrapper which will call Firebase().replyToRating internally
      await Database().replyToRating(
          ratingId: ratingId, reply: reply, productId: productId);

      // Refresh list after posting reply
      await fetchRatings();
    } catch (e, st) {
      if (kDebugMode) {
        print('replyToRating: error replying to $ratingId: $e\n$st');
      }
      emit(RatingReplyError(e.toString()));
      rethrow;
    }
  }
}
