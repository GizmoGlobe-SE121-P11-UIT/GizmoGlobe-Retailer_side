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

      final newSnapshot = await _firestore
          .collection('order_ratings')
          .where('reply', isNull: true)
          .orderBy('timeSent', descending: true)
          .limit(_pageSize)
          .get();

      final repliedSnapshot = await _firestore
          .collection('order_ratings')
          .where('reply', isNull: false)
          .orderBy('timeSent', descending: true)
          .limit(_pageSize)
          .get();

      if (kDebugMode) {
        print('fetchRatings: new=${newSnapshot.docs.length}, replied=${repliedSnapshot.docs.length}');
      }

      final List<Rating> newRatings = [];
      final List<Rating> repliedRatings = [];

      for (var doc in newSnapshot.docs) {
        try {
          final rating = Rating.fromDoc(doc);
          newRatings.add(rating);
          // populate username if possible (best effort)
          if (rating.userID.isNotEmpty) {
            try {
              final userDoc = await _firestore.collection('customers').doc(rating.userID).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName = (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (e, st) {
          if (kDebugMode) print('fetchRatings: parse new doc error ${doc.id}: $e\n$st');
        }
      }

      for (var doc in repliedSnapshot.docs) {
        try {
          final rating = Rating.fromDoc(doc);
          repliedRatings.add(rating);
          if (rating.userID.isNotEmpty) {
            try {
              final userDoc = await _firestore.collection('customers').doc(rating.userID).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName = (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (e, st) {
          if (kDebugMode) print('fetchRatings: parse replied doc error ${doc.id}: $e\n$st');
        }
      }

      // track last docs for paging
      _lastNewDoc = newSnapshot.docs.isNotEmpty ? newSnapshot.docs.last : null;
      _lastRepliedDoc = repliedSnapshot.docs.isNotEmpty ? repliedSnapshot.docs.last : null;
      _hasMoreNew = newSnapshot.docs.length >= _pageSize;
      _hasMoreReplied = repliedSnapshot.docs.length >= _pageSize;

      emit(RatingReplyLoaded(newRatings: newRatings, repliedRatings: repliedRatings, hasMoreNew: _hasMoreNew, hasMoreReplied: _hasMoreReplied));
    } catch (e, st) {
      // If Firestore complains about missing composite index (failed-precondition),
      // fall back to a client-side fetch so the app still shows data while the index is created.
      if (kDebugMode) print('fetchRatings: error fetching ratings: $e\n$st');
      final String err = e?.toString() ?? '';
      final bool missingIndex = err.contains('requires an index') || (e is FirebaseException && e.code == 'failed-precondition');
      if (missingIndex) {
        if (kDebugMode) print('fetchRatings: missing index detected, falling back to client-side fetch');
        try {
          final allSnapshot = await _firestore.collection('order_ratings').get();
          final List<Rating> fallbackNew = [];
          final List<Rating> fallbackReplied = [];
          for (var doc in allSnapshot.docs) {
            try {
              final rating = Rating.fromDoc(doc);
              if (rating.reply != null) fallbackReplied.add(rating);
              else fallbackNew.add(rating);
              // best-effort username enrichment
              if (rating.userID.isNotEmpty) {
                try {
                  final userDoc = await _firestore.collection('customers').doc(rating.userID).get();
                  if (userDoc.exists) {
                    final userData = userDoc.data();
                    final customerName = (userData?['customerName'] as String?) ?? '';
                    if (customerName.isNotEmpty) rating.username = customerName;
                  }
                } catch (_) {}
              }
            } catch (_) {
              // skip
            }
          }
          fallbackNew.sort((a, b) => b.timeSent.compareTo(a.timeSent));
          fallbackReplied.sort((a, b) => b.timeSent.compareTo(a.timeSent));
          // Use client-side pagination: store full lists and emit first page
          _usingFallback = true;
          _fallbackNewAll = fallbackNew;
          _fallbackRepliedAll = fallbackReplied;
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
          emit(RatingReplyLoaded(newRatings: firstNew, repliedRatings: firstReplied, hasMoreNew: _hasMoreNew, hasMoreReplied: _hasMoreReplied));
          return;
        } catch (e2, st2) {
          if (kDebugMode) print('fetchRatings: client-side fallback also failed: $e2\n$st2');
          emit(RatingReplyError(e2.toString()));
          return;
        }
      }

      emit(RatingReplyError(e.toString()));
    }
  }

  Future<void> loadMoreNew() async {
    if (_usingFallback) {
      // Serve next page from fallback list
      if (!_hasMoreNew) return;
      final current = state is RatingReplyLoaded ? (state as RatingReplyLoaded).newRatings : <Rating>[];
      final nextEnd = (_fallbackNewIndex + _pageSize).clamp(0, _fallbackNewAll.length);
      final more = _fallbackNewAll.sublist(_fallbackNewIndex, nextEnd);
      _fallbackNewIndex = nextEnd;
      _hasMoreNew = _fallbackNewAll.length > _fallbackNewIndex;
      final updated = [...current, ...more];
      emit(RatingReplyLoaded(newRatings: updated, repliedRatings: state is RatingReplyLoaded ? (state as RatingReplyLoaded).repliedRatings : <Rating>[], hasMoreNew: _hasMoreNew, hasMoreReplied: state is RatingReplyLoaded ? (state as RatingReplyLoaded).hasMoreReplied : false));
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
              final userDoc = await _firestore.collection('customers').doc(rating.userID).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName = (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
      final current = state is RatingReplyLoaded ? (state as RatingReplyLoaded).newRatings : <Rating>[];
      final updated = [...current, ...more];
      _lastNewDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastNewDoc;
      _hasMoreNew = snapshot.docs.length >= _pageSize;
      emit(RatingReplyLoaded(newRatings: updated, repliedRatings: state is RatingReplyLoaded ? (state as RatingReplyLoaded).repliedRatings : <Rating>[], hasMoreNew: _hasMoreNew, hasMoreReplied: state is RatingReplyLoaded ? (state as RatingReplyLoaded).hasMoreReplied : false));
    } catch (e, st) {
      if (kDebugMode) print('loadMoreNew error: $e\n$st');
    }
  }

  Future<void> loadMoreReplied() async {
    if (_usingFallback) {
      if (!_hasMoreReplied) return;
      final current = state is RatingReplyLoaded ? (state as RatingReplyLoaded).repliedRatings : <Rating>[];
      final nextEnd = (_fallbackRepliedIndex + _pageSize).clamp(0, _fallbackRepliedAll.length);
      final more = _fallbackRepliedAll.sublist(_fallbackRepliedIndex, nextEnd);
      _fallbackRepliedIndex = nextEnd;
      _hasMoreReplied = _fallbackRepliedAll.length > _fallbackRepliedIndex;
      final updated = [...current, ...more];
      emit(RatingReplyLoaded(newRatings: state is RatingReplyLoaded ? (state as RatingReplyLoaded).newRatings : <Rating>[], repliedRatings: updated, hasMoreNew: state is RatingReplyLoaded ? (state as RatingReplyLoaded).hasMoreNew : false, hasMoreReplied: _hasMoreReplied));
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
              final userDoc = await _firestore.collection('customers').doc(rating.userID).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final customerName = (userData?['customerName'] as String?) ?? '';
                if (customerName.isNotEmpty) rating.username = customerName;
              }
            } catch (_) {}
          }
        } catch (_) {}
      }
      final current = state is RatingReplyLoaded ? (state as RatingReplyLoaded).repliedRatings : <Rating>[];
      final updated = [...current, ...more];
      _lastRepliedDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastRepliedDoc;
      _hasMoreReplied = snapshot.docs.length >= _pageSize;
      emit(RatingReplyLoaded(newRatings: state is RatingReplyLoaded ? (state as RatingReplyLoaded).newRatings : <Rating>[], repliedRatings: updated, hasMoreNew: state is RatingReplyLoaded ? (state as RatingReplyLoaded).hasMoreNew : false, hasMoreReplied: _hasMoreReplied));
    } catch (e, st) {
      if (kDebugMode) print('loadMoreReplied error: $e\n$st');
    }
  }

  /// Post a reply to a rating. Constructs a `Reply` object and calls Database().replyToRating.
  Future<void> replyToRating({required String ratingId, required String comment, String? productId}) async {
    try {
      final reply = Reply(id: DateTime.now().millisecondsSinceEpoch.toString(), comment: comment, timestamp: DateTime.now());

      // Use Database wrapper which will call Firebase().replyToRating internally
      await Database().replyToRating(ratingId: ratingId, reply: reply, productId: productId);

      // Refresh list after posting reply
      await fetchRatings();
    } catch (e, st) {
      if (kDebugMode) print('replyToRating: error replying to $ratingId: $e\n$st');
      emit(RatingReplyError(e.toString()));
      rethrow;
    }
  }
}
