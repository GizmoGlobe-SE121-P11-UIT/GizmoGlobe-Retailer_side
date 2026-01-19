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
  bool _isClosed = false;

  ChatListScreenCubit() : super(const ChatListScreenState()) {
    _initialize();
  }

  /// Safely emits a new state, handling the case where the cubit may be closed
  /// due to race conditions with stream listeners.
  void _safeEmit(ChatListScreenState newState) {
    // Check both our custom flag and the built-in isClosed getter
    if (_isClosed || isClosed) return;

    try {
      emit(newState);
    } catch (e) {
      // Ignore errors from attempting to emit after close
    }
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

    // Listen to chats collection for real-time updates
    _chatsSubscription?.cancel();
    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .snapshots()
        .listen((snapshot) async {
      // Don't process if cubit is closed
      if (_isClosed || isClosed) return;

      try {
        // Create a map to store conversations per user
        final Map<String, List<Chat>> conversations = {};
        final Set<String> allUserIds = {};

        // Process each user's chat document
        for (var userDoc in snapshot.docs) {
          final userId = userDoc.id;
          final data = userDoc.data();
          final messages = (data['messages'] as List<dynamic>?) ?? [];

          // Get all messages involving admin (both sent and received)
          final adminMessages = messages
              .where((msg) =>
                  (msg['receiverId'] == 'admin' ||
                      msg['senderId'] == 'admin') &&
                  msg['isAIMode'] == false)
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

          // If this user has any admin messages, create a conversation for them
          if (adminMessages.isNotEmpty) {
            conversations[userId] = adminMessages;
            allUserIds.add(userId);
          }
        }

        // Fetch usernames for all userIds
        final Map<String, String> userIdToUsername = {};
        for (final id in allUserIds) {
          userIdToUsername[id] = await _getUsernameFromUserId(id);
        }
        userIdToUsername['admin'] = 'Admin';

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

        _safeEmit(state.copyWith(
          isLoading: false,
          conversations: sortedConversations,
          currentUserId: userId,
          userIdToUsername: userIdToUsername,
        ));
      } catch (e) {
        // Error in real-time chat list
        _safeEmit(state.copyWith(
          isLoading: false,
          error: 'Failed to load chats',
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _chatsSubscription?.cancel();
    _chatsSubscription = null;
    return super.close();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      final chat = Chat(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'admin',
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isAIMode: false,
      );

      // Send message from admin to the user
      await _firebase.sendAdminMessage(receiverId, chat);

      // Update local state - conversation key is the userId
      final updatedConversations =
          Map<String, List<Chat>>.from(state.conversations);
      if (!updatedConversations.containsKey(receiverId)) {
        updatedConversations[receiverId] = [];
      }
      updatedConversations[receiverId] = [
        ...updatedConversations[receiverId]!,
        chat
      ];

      _safeEmit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      // Error sending message
      _safeEmit(state.copyWith(error: 'Failed to send message'));
    }
  }

  Future<void> markAsRead(String messageId, String userId) async {
    try {
      await _firebase.markAdminMessageAsRead(userId, messageId);

      // Update local state - conversation key is the userId
      final updatedConversations =
          Map<String, List<Chat>>.from(state.conversations);
      if (updatedConversations.containsKey(userId)) {
        updatedConversations[userId] =
            updatedConversations[userId]!.map((chat) {
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

      _safeEmit(state.copyWith(conversations: updatedConversations));
    } catch (e) {
      // Error marking message as read
    }
  }

  Future<void> loadConversation(String userId) async {
    try {
      // Get messages for this specific user from Firebase
      final userDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final messages = (data['messages'] as List<dynamic>?) ?? [];

        final adminMessages = messages
            .where((msg) =>
                (msg['receiverId'] == 'admin' || msg['senderId'] == 'admin') &&
                msg['isAIMode'] == false)
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

        adminMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final updatedConversations =
            Map<String, List<Chat>>.from(state.conversations);
        updatedConversations[userId] = adminMessages;

        _safeEmit(state.copyWith(conversations: updatedConversations));
      }
    } catch (e) {
      // Error loading conversation
    }
  }
}
