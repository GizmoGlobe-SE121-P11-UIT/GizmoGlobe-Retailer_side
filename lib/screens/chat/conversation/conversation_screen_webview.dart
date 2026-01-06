import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'conversation_screen_cubit.dart';
import 'conversation_screen_state.dart';

class ConversationScreenWebView extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final VoidCallback? onBackPressed;

  const ConversationScreenWebView({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.onBackPressed,
  });

  static Widget newInstance({
    required String receiverId,
    required String receiverName,
  }) =>
      BlocProvider(
        create: (context) => ConversationScreenCubit(
          receiverId: receiverId,
          receiverName: receiverName,
        ),
        child: ConversationScreenWebView(
          receiverId: receiverId,
          receiverName: receiverName,
        ),
      );

  @override
  State<ConversationScreenWebView> createState() =>
      _ConversationScreenWebViewState();
}

class _ConversationScreenWebViewState extends State<ConversationScreenWebView> {
  ConversationScreenCubit get cubit => context.read<ConversationScreenCubit>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Handle back button on mobile/web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Listen for system back button (Android) or browser back
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    // Return to chat list - call the parent's callback if provided
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: BlocBuilder<ConversationScreenCubit, ConversationScreenState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back/chevron button - always visible when in conversation
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        iconSize: isMobile ? 24 : 28,
                        onPressed: _handleBack,
                        tooltip: S.of(context).backToChatList,
                        padding: EdgeInsets.all(isMobile ? 8 : 4),
                        constraints: BoxConstraints(
                          minWidth: isMobile ? 40 : 44,
                          minHeight: isMobile ? 40 : 44,
                        ),
                      ),
                      SizedBox(width: isMobile ? 4 : 8),
                      CircleAvatar(
                        radius: isMobile ? 18 : 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          widget.receiverName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: Text(
                          widget.receiverName,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 18 : null,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages Area
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                          ? Center(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        state.error!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : state.messages.isEmpty
                              ? Center(
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            S.of(context).noMessages,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  itemCount: state.messages.length,
                                  itemBuilder: (context, index) {
                                    final chat = state.messages[index];
                                    final isMe = chat.senderId == 'admin';

                                    // Mark message as read if it's from the other user
                                    if (!isMe && !chat.isRead) {
                                      cubit.markAsRead(
                                          chat.messageId, chat.senderId);
                                    }

                                    return Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: isMobile
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.75
                                              : 400,
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: isMobile ? 6 : 8,
                                          left: isMobile ? 4 : 0,
                                          right: isMobile ? 4 : 0,
                                        ),
                                        padding:
                                            EdgeInsets.all(isMobile ? 10 : 12),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius: BorderRadius.circular(
                                              isMobile ? 12 : 16),
                                        ),
                                        child: Text(
                                          chat.content,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                            fontSize: isMobile ? 14 : null,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),

                // Message Input Area
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: S.of(context).typeMessage,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 20 : 24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 10 : 12,
                            ),
                            hintStyle: TextStyle(
                              fontSize: isMobile ? 14 : null,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isMobile ? 14 : null,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              cubit.sendMessage(value);
                              _messageController.clear();
                              _scrollToBottom();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(isMobile ? 20 : 24),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_messageController.text.isNotEmpty) {
                              cubit.sendMessage(_messageController.text);
                              _messageController.clear();
                              _scrollToBottom();
                            }
                          },
                          icon: Icon(
                            Icons.send_rounded,
                            size: isMobile ? 20 : 24,
                          ),
                          color: Colors.white,
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
