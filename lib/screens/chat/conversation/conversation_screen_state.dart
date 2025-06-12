import 'package:equatable/equatable.dart';
import '../../../objects/chat_related/chat.dart';

class ConversationScreenState extends Equatable {
  final List<Chat> messages;
  final bool isLoading;
  final String? error;
  final String currentUserId;
  final String receiverId;
  final String receiverName;

  const ConversationScreenState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentUserId = '',
    this.receiverId = '',
    this.receiverName = '',
  });

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        error,
        currentUserId,
        receiverId,
        receiverName,
      ];

  ConversationScreenState copyWith({
    List<Chat>? messages,
    bool? isLoading,
    String? error,
    String? currentUserId,
    String? receiverId,
    String? receiverName,
  }) {
    return ConversationScreenState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
    );
  }
}
