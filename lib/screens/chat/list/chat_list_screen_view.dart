import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/widgets/chat/chat_card.dart';
import 'package:gizmoglobe_client/screens/chat/conversation/conversation_screen_view.dart';
import 'chat_list_screen_cubit.dart';
import 'chat_list_screen_state.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => ChatListScreenCubit(),
        child: const ChatListScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListScreenCubit, ChatListScreenState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(S.of(context).messages),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text(state.error!))
                  : state.conversations.isEmpty
                      ? Center(
                          child: Text(
                            S.of(context).noMessages,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.conversations.length,
                          itemBuilder: (context, index) {
                            final entry =
                                state.conversations.entries.elementAt(index);
                            final chats = entry.value;
                            final lastChat =
                                chats.isNotEmpty ? chats.last : null;
                            final unreadCount =
                                chats.where((chat) => !chat.isRead).length;

                            if (lastChat == null)
                              return const SizedBox.shrink();

                            // Determine the userId for display (not admin)
                            String userId = lastChat.senderId == 'admin'
                                ? lastChat.receiverId
                                : lastChat.senderId;
                            if (userId == 'admin') userId = lastChat.senderId;
                            final displayName =
                                state.userIdToUsername[userId] ?? userId;

                            return ChatCard(
                              lastChat: lastChat,
                              unreadCount: unreadCount,
                              currentUserId: state.currentUserId,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ConversationScreen.newInstance(
                                      receiverId: userId,
                                      receiverName: displayName,
                                    ),
                                  ),
                                );
                              },
                              displayName: displayName,
                            );
                          },
                        ),
        );
      },
    );
  }
}
