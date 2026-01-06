import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
import '../../../objects/chat_related/chat.dart';
import 'conversation_screen_state.dart';

class ConversationScreenCubit extends Cubit<ConversationScreenState> {
  final Database db = Database();
  final Firebase _firebase = Firebase();
  StreamSubscription? _chatSubscription;
  bool _isClosed = false;

  ConversationScreenCubit({
    required String receiverId,
    required String receiverName,
  }) : super(ConversationScreenState(
          receiverId: receiverId,
          receiverName: receiverName,
        )) {
    _initialize();
  }

  /// Safely emits a new state, handling the case where the cubit may be closed
  /// due to race conditions with stream listeners.
  void _safeEmit(ConversationScreenState newState) {
    // Check both our custom flag and the built-in isClosed getter
    if (_isClosed || isClosed) return;

    try {
      emit(newState);
    } catch (e) {
      // Ignore errors from attempting to emit after close
    }
  }

  Future<void> _initialize() async {
    if (_isClosed || isClosed) return;

    _safeEmit(state.copyWith(isLoading: true));
    await db.initialize();
    final userId = db.userId;

    if (userId == null) {
      _safeEmit(state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
      ));
      return;
    }

    // Listen to the selected user's chat document in real-time
    _chatSubscription?.cancel();
    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(state.receiverId)
        .snapshots()
        .listen((doc) {
      // Don't process if cubit is closed
      if (_isClosed || isClosed) return;

      try {
        final data = doc.data();
        final messages = (data?['messages'] as List<dynamic>? ?? [])
            .map((msg) {
              final map = msg as Map<String, dynamic>;
              if (map['timestamp'] is Timestamp) {
                map['timestamp'] = (map['timestamp'] as Timestamp).toDate();
              } else if (map['timestamp'] is int) {
                map['timestamp'] = DateTime.fromMillisecondsSinceEpoch(
                    map['timestamp'] as int);
              }
              return Chat.fromMap(map);
            })
            .where((msg) =>
                (msg.receiverId == 'admin' && msg.isAIMode == false) ||
                (msg.senderId == 'admin' &&
                    msg.receiverId == state.receiverId &&
                    msg.isAIMode == false))
            .toList();
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Use _safeEmit to handle race conditions
        _safeEmit(state.copyWith(
          isLoading: false,
          messages: messages,
          currentUserId: userId,
        ));
      } catch (e) {
        // Error reading conversation

        // Use _safeEmit to handle race conditions
        _safeEmit(state.copyWith(
          isLoading: false,
          error: 'Failed to load messages',
        ));
      }
    }, onError: (error) {
      // Handle stream errors without emitting if closed
      // Chat stream error
    });
  }

  Future<void> sendMessage(String content) async {
    if (_isClosed || isClosed) return;

    try {
      final chat = Chat(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'admin',
        receiverId: state.receiverId,
        content: content,
        timestamp: DateTime.now(),
        isAIMode: false,
      );
      // Upload reply to the user's messages array
      await _firebase.sendAdminMessage(state.receiverId, chat);
    } catch (e) {
      // Error sending message
      _safeEmit(state.copyWith(error: 'Failed to send message'));
    }
  }

  Future<void> markAsRead(String messageId, String senderId) async {
    try {
      await _firebase.markAdminMessageAsRead(state.receiverId, messageId);
    } catch (e) {
      // Error marking message as read
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _chatSubscription?.cancel();
    _chatSubscription = null;
    return super.close();
  }
}
