import 'package:equatable/equatable.dart';
import '../../../objects/chat_related/chat.dart';

class ChatListScreenState extends Equatable {
  final List<Chat> chats;
  final bool isLoading;
  final String? error;
  final String currentUserId;
  final Map<String, List<Chat>>
      conversations; // Map of receiverId to chat messages
  final Map<String, String> userIdToUsername;

  const ChatListScreenState({
    this.chats = const [],
    this.isLoading = false,
    this.error,
    this.currentUserId = '',
    this.conversations = const {},
    this.userIdToUsername = const {},
  });

  @override
  List<Object?> get props =>
      [chats, isLoading, error, currentUserId, conversations, userIdToUsername];

  ChatListScreenState copyWith({
    List<Chat>? chats,
    bool? isLoading,
    String? error,
    String? currentUserId,
    Map<String, List<Chat>>? conversations,
    Map<String, String>? userIdToUsername,
  }) {
    return ChatListScreenState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
      conversations: conversations ?? this.conversations,
      userIdToUsername: userIdToUsername ?? this.userIdToUsername,
    );
  }
}
