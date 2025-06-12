import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/objects/chat_related/chat.dart';

class ChatCard extends StatelessWidget {
  final Chat lastChat;
  final int unreadCount;
  final String currentUserId;
  final VoidCallback onTap;
  final String displayName;

  const ChatCard({
    super.key,
    required this.lastChat,
    required this.unreadCount,
    required this.currentUserId,
    required this.onTap,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            displayName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          lastChat.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unreadCount > 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
