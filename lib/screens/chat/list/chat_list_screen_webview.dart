import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/chat/chat_card.dart';
import 'package:gizmoglobe_client/screens/chat/conversation/conversation_screen_webview.dart';
import 'package:gizmoglobe_client/screens/chat/conversation/conversation_screen_cubit.dart';
import 'package:gizmoglobe_client/components/general/web_header.dart';
import 'package:gizmoglobe_client/components/general/web_sidebar.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_view.dart';
import 'package:gizmoglobe_client/screens/user/user_screen/user_screen_view.dart';
import 'chat_list_screen_cubit.dart';
import 'chat_list_screen_state.dart';

class ChatListScreenWebView extends StatefulWidget {
  final String? selectedChatId;

  const ChatListScreenWebView({super.key, this.selectedChatId});

  static Widget newInstance({String? selectedChatId}) => BlocProvider(
        create: (context) => ChatListScreenCubit(),
        child: ChatListScreenWebView(selectedChatId: selectedChatId),
      );

  @override
  State<ChatListScreenWebView> createState() => _ChatListScreenWebViewState();
}

class _ChatListScreenWebViewState extends State<ChatListScreenWebView> {
  bool isSidebarCompact = true; // Start compact by default for chat
  String? selectedChatId;
  String? selectedChatName;
  int mainSidebarIndex = 0; // Track main sidebar selection

  @override
  void initState() {
    super.initState();
    // Initialize with the selected chat ID from URL if provided
    selectedChatId = widget.selectedChatId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the selected chat name when the state is available
    if (selectedChatId != null && selectedChatName == null) {
      final state = context.read<ChatListScreenCubit>().state;
      selectedChatName =
          state.userIdToUsername[selectedChatId] ?? selectedChatId;
    }
  }

  void _updateUrl(String? chatId) {
    if (kIsWeb) {
      if (chatId != null) {
        // Update URL with chat ID
        PlatformSpecificUtils.pushState('/#/chat?id=$chatId');
      } else {
        // Update URL without chat ID
        PlatformSpecificUtils.pushState('/#/chat');
      }
    }
  }

  Widget _getMainContentWidget() {
    switch (mainSidebarIndex) {
      case 1:
        return ProductScreen.newInstance();
      case 2:
        return InvoiceScreen.newInstance();
      case 3:
        return StakeholderScreen.newInstance();
      case 4:
        return VoucherScreen.newInstance();
      case 5:
        return UserScreen.newInstance();
      default:
        return Container(); // This should not be reached
    }
  }

  Widget _buildChatInterface(ChatListScreenState state) {
    return Row(
      children: [
        // Chat List Sidebar
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Chat List Header
              Container(
                padding: const EdgeInsets.all(16),
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
                    Text(
                      S.of(context).messages,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    // Only show close button when there is a selected conversation
                    if (selectedChatId != null && selectedChatName != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedChatId = null;
                            selectedChatName = null;
                          });
                          // Update URL when conversation is closed
                          _updateUrl(null);
                        },
                        icon: const Icon(Icons.close),
                        tooltip: 'Close conversation',
                      ),
                  ],
                ),
              ),

              // Chat List
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.error!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                          )
                        : state.conversations.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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
                                            .bodyMedium
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
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: state.conversations.length,
                                itemBuilder: (context, index) {
                                  final entry = state.conversations.entries
                                      .elementAt(index);
                                  final chats = entry.value;
                                  final lastChat =
                                      chats.isNotEmpty ? chats.last : null;
                                  final unreadCount = chats
                                      .where((chat) => !chat.isRead)
                                      .length;

                                  if (lastChat == null) {
                                    return const SizedBox.shrink();
                                  }

                                  // Determine the userId for display (not admin)
                                  String userId = lastChat.senderId == 'admin'
                                      ? lastChat.receiverId
                                      : lastChat.senderId;
                                  if (userId == 'admin') {
                                    userId = lastChat.senderId;
                                  }
                                  final displayName =
                                      state.userIdToUsername[userId] ?? userId;

                                  return ChatCard(
                                    lastChat: lastChat,
                                    unreadCount: unreadCount,
                                    currentUserId: state.currentUserId,
                                    onTap: () {
                                      setState(() {
                                        selectedChatId = userId;
                                        selectedChatName = displayName;
                                      });
                                      // Update URL when chat is selected
                                      _updateUrl(userId);
                                    },
                                    displayName: displayName,
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),

        // Conversation Content Area
        Expanded(
          child: selectedChatId != null && selectedChatName != null
              ? BlocProvider(
                  create: (context) => ConversationScreenCubit(
                    receiverId: selectedChatId!,
                    receiverName: selectedChatName!,
                  ),
                  child: ConversationScreenWebView(
                    receiverId: selectedChatId!,
                    receiverName: selectedChatName!,
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a conversation to start chatting',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListScreenCubit, ChatListScreenState>(
      builder: (context, state) {
        // Calculate unread chats count
        final unreadChats = state.conversations.values
            .expand((chats) => chats)
            .where(
                (chat) => !chat.isRead && chat.senderId != state.currentUserId)
            .length;

        return Scaffold(
          body: Column(
            children: [
              // Web Header - spans above all content
              WebHeader(
                unreadChats: unreadChats,
                onChatPressed: () {
                  // Already on chat screen, no action needed
                },
              ),

              // Main content area with sidebars
              Expanded(
                child: Row(
                  children: [
                    // Main Sidebar
                    WebSidebarModes(
                      currentIndex: mainSidebarIndex,
                      initialCompactMode:
                          true, // Start compact for chat interface
                      onItemSelected: (index) {
                        // Handle sidebar navigation
                        if (index == 0) {
                          // Home - navigate to main screen
                          if (kIsWeb) {
                            PlatformSpecificUtils.replaceState('/#/main');
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/main',
                              (route) => false,
                            );
                          }
                        } else if (index == 2) {
                          // Invoices - navigate to invoices screen
                          if (kIsWeb) {
                            PlatformSpecificUtils.replaceState('/#/invoices');
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/invoices',
                              (route) => false,
                            );
                          }
                        } else if (index == 3) {
                          // Stakeholders - navigate to stakeholders screen
                          if (kIsWeb) {
                            PlatformSpecificUtils.replaceState(
                                '/#/stakeholders');
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/stakeholders',
                              (route) => false,
                            );
                          }
                        } else if (index == 4) {
                          // Vouchers - navigate to vouchers screen
                          if (kIsWeb) {
                            PlatformSpecificUtils.replaceState('/#/vouchers');
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/vouchers',
                              (route) => false,
                            );
                          }
                        } else {
                          // Other sections - handle natively within chat screen
                          setState(() {
                            mainSidebarIndex = index;
                          });
                        }
                      },
                      items: buildDefaultSidebarItems(
                        home: S.of(context).home,
                        product: S.of(context).product,
                        invoice: S.of(context).invoice,
                        stakeholder: S.of(context).stakeholder,
                        voucher: S.of(context).voucher,
                        profile: S.of(context).profile,
                      ),
                      onCompactModeChanged: (compact) {
                        setState(() {
                          isSidebarCompact = compact;
                        });
                      },
                    ),

                    // Main Content Area - Show either chat interface or main content
                    Expanded(
                      child: mainSidebarIndex == 0
                          ? _buildChatInterface(state)
                          : _getMainContentWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
