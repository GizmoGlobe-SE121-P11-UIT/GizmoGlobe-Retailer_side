import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
import '../../../objects/chat_related/chat.dart';
import 'chat_list_screen_state.dart';
import 'dart:async';

class ChatListScreenCubit extends Cubit<ChatListScreenState> {
  final Database db = Database();
  final Firebase _firebase = Firebase();
  StreamSubscription? _chatsSubscription;

  ChatListScreenCubit() : super(const ChatListScreenState()) {
    _initialize();
  }

  Future<String> _getUsernameFromUserId(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['username'] ?? userId;
      }
      return userId;
    } catch (e) {
      return userId;
    }
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

    if (kDebugMode) {
      print('Initializing chat list for user: $userId');
    }

    // Listen to chats collection for real-time updates
    _chatsSubscription?.cancel();
    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .snapshots()
        .listen((snapshot) async {
      try {
        final List<Chat> allAdminMessages = [];
        for (var userDoc in snapshot.docs) {
          final userId = userDoc.id;
          final data = userDoc.data();
          final messages = (data['messages'] as List<dynamic>?) ?? [];
          final adminMessages = messages
              .where((msg) =>
                  msg['receiverId'] == 'admin' && msg['isAIMode'] == false)
              .map((msg) {
            final map = msg as Map<String, dynamic>;
            if (map['timestamp'] is Timestamp) {
              map['timestamp'] = (map['timestamp'] as Timestamp).toDate();
            } else if (map['timestamp'] is int) {
              map['timestamp'] =
                  DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
            }
            return Chat.fromMap(map);
          }).toList();
          allAdminMessages.addAll(adminMessages);
        }

        // Filter messages for current user
        final userAdminMessages = allAdminMessages
            .where((msg) =>
                (msg.receiverId == 'admin') || (msg.senderId == 'admin'))
            .toList();

        // Get all unique userIds (excluding admin)
        final userIds = userAdminMessages
            .map((chat) =>
                chat.senderId == 'admin' ? chat.receiverId : chat.senderId)
            .where((id) => id != 'admin')
            .toSet();

        // Fetch usernames for all userIds
        final Map<String, String> userIdToUsername = {};
        for (final id in userIds) {
          userIdToUsername[id] = await _getUsernameFromUserId(id);
        }
        userIdToUsername['admin'] = 'Admin';

        // Create conversations map
        final conversations = <String, List<Chat>>{
          'admin': userAdminMessages,
        };
        // Sort messages in each conversation by timestamp ascending
        conversations.forEach((key, value) {
          value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
        // Sort conversations by last message timestamp (descending)
        final sortedConversations = Map.fromEntries(
          conversations.entries.toList()
            ..sort((a, b) {
              final aLastMessage = a.value.isNotEmpty
                  ? a.value.last.timestamp
                  : DateTime.fromMillisecondsSinceEpoch(0);
              final bLastMessage = b.value.isNotEmpty
                  ? b.value.last.timestamp
                  : DateTime.fromMillisecondsSinceEpoch(0);
              return bLastMessage.compareTo(aLastMessage);
            }),
        );
        emit(state.copyWith(
          isLoading: false,
          conversations: sortedConversations,
          currentUserId: userId,
          userIdToUsername: userIdToUsername,
        ));
      } catch (e) {
        if (kDebugMode) {
          print('Error in real-time chat list: $e');
        }
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load chats',
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      if (kDebugMode) {
        print('Sending message to $receiverId: $content');
      }

      final chat = Chat(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: state.currentUserId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isAIMode: false,
      );

      // Send message to admin
      await _firebase.sendAdminMessage(state.currentUserId, chat);

      // Update local state
      final updatedConversations =
          Map<String, List<Chat>>.from(state.conversations);
      if (!updatedConversations.containsKey('admin')) {
        updatedConversations['admin'] = [];
      }
      updatedConversations['admin'] = [...updatedConversations['admin']!, chat];

      if (kDebugMode) {
        print('Updated conversations: ${updatedConversations.keys.toList()}');
      }

      emit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      emit(state.copyWith(error: 'Failed to send message'));
    }
  }

  Future<void> markAsRead(String messageId, String senderId) async {
    try {
      await _firebase.markAdminMessageAsRead(state.currentUserId, messageId);

      // Update local state
      final updatedConversations =
          Map<String, List<Chat>>.from(state.conversations);
      if (updatedConversations.containsKey('admin')) {
        updatedConversations['admin'] =
            updatedConversations['admin']!.map((chat) {
          if (chat.messageId == messageId) {
            return Chat(
              messageId: chat.messageId,
              senderId: chat.senderId,
              receiverId: chat.receiverId,
              content: chat.content,
              timestamp: chat.timestamp,
              isRead: true,
              isAIMode: chat.isAIMode,
            );
          }
          return chat;
        }).toList();
      }

      emit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as read: $e');
      }
    }
  }

  Future<void> loadConversation(String receiverId) async {
    try {
      if (kDebugMode) {
        print('Loading conversation with $receiverId');
      }

      final allMessages = await _firebase.getAllUsersAdminMessages();
      final messages = allMessages
          .where(
              (msg) => (msg.receiverId == 'admin') || msg.senderId == 'admin')
          .toList();

      if (kDebugMode) {
        print('Loaded ${messages.length} messages');
      }

      final updatedConversations =
          Map<String, List<Chat>>.from(state.conversations);
      updatedConversations['admin'] = messages;

      emit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversation: $e');
      }
    }
  }
}
