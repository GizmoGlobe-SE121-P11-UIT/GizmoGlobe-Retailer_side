import 'dart:async';
import 'package:flutter/foundation.dart';
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

  ConversationScreenCubit({
    required String receiverId,
    required String receiverName,
  }) : super(ConversationScreenState(
          receiverId: receiverId,
          receiverName: receiverName,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(state.copyWith(isLoading: true));
    await db.initialize();
    final userId = db.userId;

    if (userId == null) {
      emit(state.copyWith(
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
      try {
        final data = doc.data() as Map<String, dynamic>?;
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
        emit(state.copyWith(
          isLoading: false,
          messages: messages,
          currentUserId: userId,
        ));
      } catch (e) {
        if (kDebugMode) {
          print('Error reading conversation: $e');
        }
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load messages',
        ));
      }
    });
  }

  Future<void> sendMessage(String content) async {
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
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      emit(state.copyWith(error: 'Failed to send message'));
    }
  }

  Future<void> markAsRead(String messageId, String senderId) async {
    try {
      await _firebase.markAdminMessageAsRead(state.receiverId, messageId);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as read: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
