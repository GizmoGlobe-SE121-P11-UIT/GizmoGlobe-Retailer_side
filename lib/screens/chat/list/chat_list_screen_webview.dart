import 'dart:async';
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
  int mainSidebarIndex = 0; // Track main sidebar selection (no-op navigation)
  StreamSubscription<dynamic>? _hashChangeSubscription;

  // Mobile sidebar state
  bool isMobileSidebarVisible = false;
  // Note: Chat list visibility is now controlled by selectedChatId (null = show list, not null = show conversation)

  // Mobile breakpoint threshold
  static const double mobileBreakpoint = 900.0;
  // Compact breakpoint - auto-compact sidebar on medium screens
  static const double compactBreakpoint = 1100.0;

  bool _isMobileMode(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  void _toggleMobileSidebar() {
    setState(() {
      isMobileSidebarVisible = !isMobileSidebarVisible;
    });
  }

  void _closeMobileSidebar() {
    if (isMobileSidebarVisible) {
      setState(() {
        isMobileSidebarVisible = false;
      });
    }
  }

  // Chat list toggle removed - using replacement pattern instead of overlay
  // Chat list visibility is now directly controlled by selectedChatId (null = show list, not null = show conversation)

  @override
  void initState() {
    super.initState();
    // Initialize with the selected chat ID from URL if provided
    selectedChatId = widget.selectedChatId;

    // Chat list visibility is now controlled by selectedChatId in the UI
    // No need to set isChatListVisible here

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _parseUrlParameters();
            }
          });
        }
      });
      // Also parse initial URL parameters
      _parseUrlParameters();
    }
  }

  @override
  void dispose() {
    _hashChangeSubscription?.cancel();
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      // The URL format is /#/chat or /#/chat/userId (path-based, not query params)
      final fragment = uri.fragment; // e.g., "/chat" or "/chat/userId"
      String? newChatId;

      if (fragment.isNotEmpty && fragment.startsWith('/chat')) {
        // Split the fragment path to extract the chat ID
        // /chat -> no ID, /chat/userId -> userId
        final pathSegments = fragment.split('/');
        // pathSegments: ['', 'chat'] or ['', 'chat', 'userId']
        if (pathSegments.length >= 3 && pathSegments[2].isNotEmpty) {
          newChatId = pathSegments[2];
        }
      }

      if (newChatId != selectedChatId) {
        String? chatName;
        // Try to get the name immediately if state is available
        if (newChatId != null && mounted) {
          try {
            final state = context.read<ChatListScreenCubit>().state;
            if (state.userIdToUsername.isNotEmpty) {
              chatName = state.userIdToUsername[newChatId] ?? newChatId;
            }
          } catch (e) {
            // Context might not be ready yet, will be fetched in listener
          }
        }

        setState(() {
          selectedChatId = newChatId;
          selectedChatName =
              chatName; // Set name if available, null otherwise (will be fetched by listener)
          // Adjust chat list visibility - hide when conversation selected, show when none selected
          // Simplified: chat list visibility is now controlled by selectedChatId being null
          // No need to manually set isChatListVisible here as the UI checks selectedChatId directly
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the selected chat name when the state is available
    if (selectedChatId != null && selectedChatName == null) {
      final state = context.read<ChatListScreenCubit>().state;
      if (state.userIdToUsername.isNotEmpty) {
        selectedChatName =
            state.userIdToUsername[selectedChatId] ?? selectedChatId;
      }
    }
    // Chat list visibility is now controlled directly by selectedChatId in the UI
    // No need to manually adjust isChatListVisible here
  }

  void _updateUrl(String? chatId) {
    if (kIsWeb) {
      if (chatId != null) {
        // Update URL with chat ID using path-based format
        PlatformSpecificUtils.pushState('/#/chat/$chatId');
      } else {
        // Update URL without chat ID
        PlatformSpecificUtils.pushState('/#/chat');
      }
    }
  }

  Widget _getMainContentWidget() {
    // Always show chat interface in this screen; cross-section navigation is handled by WebSidebarModes
    return _buildChatInterface(context.read<ChatListScreenCubit>().state);
  }

  Widget _buildChatInterface(ChatListScreenState state) {
    final isMobile = _isMobileMode(context);

    // Both mobile and desktop use the same replacement pattern:
    // Initially show chat list, replace with conversation when selected
    return Stack(
      children: [
        // Main conversation area - replaces chat list when selected
        // Show conversation when both id and name are available
        // Show loading when id is set but name is still pending
        // Show placeholder only when no chat is selected
        if (selectedChatId != null && selectedChatName != null)
          BlocProvider(
            key: ValueKey('conversation_$selectedChatId'),
            create: (context) => ConversationScreenCubit(
              receiverId: selectedChatId!,
              receiverName: selectedChatName!,
            ),
            child: ConversationScreenWebView(
              receiverId: selectedChatId!,
              receiverName: selectedChatName!,
              onBackPressed: () {
                setState(() {
                  selectedChatId = null;
                  selectedChatName = null;
                  // Chat list will automatically show when selectedChatId is null
                });
                // Update URL when conversation is closed
                _updateUrl(null);
              },
            ),
          )
        else if (selectedChatId != null && selectedChatName == null)
          // Loading state - waiting for username to be fetched
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          // No conversation selected - show placeholder
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: isMobile ? 48 : 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                    child: Text(
                      'Select a conversation to start chatting',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isMobile ? 14 : null,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Chat list - shown when no conversation is selected (replacement pattern for both mobile and desktop)
        if (selectedChatId == null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: _buildChatListSidebar(state, isMobile),
            ),
          ),
      ],
    );
  }

  Widget _buildChatListSidebar(ChatListScreenState state, bool isMobile) {
    return Column(
      children: [
        // Chat List Header
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
          child: Text(
            S.of(context).messages,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : null,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Chat List
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isMobile ? 40 : 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              state.error!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: isMobile ? 13 : null,
                                    color: Theme.of(context).colorScheme.error,
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
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: isMobile ? 40 : 48,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                SizedBox(height: isMobile ? 12 : 16),
                                Text(
                                  S.of(context).noMessages,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: isMobile ? 13 : null,
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
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          itemCount: state.conversations.length,
                          itemBuilder: (context, index) {
                            final entry =
                                state.conversations.entries.elementAt(index);
                            final chats = entry.value;
                            final lastChat =
                                chats.isNotEmpty ? chats.last : null;
                            final unreadCount =
                                chats.where((chat) => !chat.isRead).length;

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
                                  // Chat list will automatically hide when selectedChatId is set (replacement pattern)
                                  // Also close main sidebar if open
                                  if (isMobileSidebarVisible) {
                                    isMobileSidebarVisible = false;
                                  }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatListScreenCubit, ChatListScreenState>(
      listener: (context, state) {
        // Update selectedChatName when state becomes available and we have a selectedChatId
        if (!mounted) return;

        if (selectedChatId != null &&
            selectedChatName == null &&
            state.userIdToUsername.isNotEmpty) {
          final chatName =
              state.userIdToUsername[selectedChatId] ?? selectedChatId;
          if (selectedChatName != chatName) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && selectedChatId != null) {
                setState(() {
                  selectedChatName = chatName;
                  // Chat list visibility is controlled by selectedChatId (null check in UI)
                });
              }
            });
          }
        }
      },
      builder: (context, state) {
        // Calculate unread chats count
        final unreadChats = state.conversations.values
            .expand((chats) => chats)
            .where(
                (chat) => !chat.isRead && chat.senderId != state.currentUserId)
            .length;

        final isMobile = _isMobileMode(context);
        final screenWidth = MediaQuery.of(context).size.width;
        final shouldAutoCompact = screenWidth < compactBreakpoint && !isMobile;

        return Scaffold(
          body: Column(
            children: [
              // Web Header - spans above all content
              WebHeader(
                unreadChats: unreadChats,
                onChatPressed: () {
                  // Already on chat screen, no action needed
                },
                isMobileMode: isMobile,
                onMenuPressed: _toggleMobileSidebar,
              ),

              // Main content area with sidebars
              Expanded(
                child: Stack(
                  children: [
                    // Main Content Area - Desktop uses Row layout, Mobile uses full overlay
                    if (!isMobile)
                      Row(
                        children: [
                          // Desktop sidebar - part of Row layout
                          WebSidebarModes(
                            currentIndex: mainSidebarIndex,
                            initialCompactMode: shouldAutoCompact,
                            onItemSelected: (index) {
                              setState(() {
                                mainSidebarIndex = index;
                              });
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
                          Expanded(
                            child: mainSidebarIndex == 0
                                ? _buildChatInterface(state)
                                : _getMainContentWidget(),
                          ),
                        ],
                      )
                    else
                      // Mobile: content fills entire space, sidebar overlays on top
                      mainSidebarIndex == 0
                          ? _buildChatInterface(state)
                          : _getMainContentWidget(),

                    // Mobile sidebar overlay - backdrop first (behind sidebar)
                    if (isMobile && isMobileSidebarVisible) ...[
                      // Backdrop
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _closeMobileSidebar,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      // Sidebar drawer - on top of backdrop
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Material(
                          elevation: 16,
                          child: Container(
                            width: screenWidth * 0.85,
                            constraints: const BoxConstraints(maxWidth: 300),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(2, 0),
                                ),
                              ],
                            ),
                            child: WebSidebarModes(
                              currentIndex: mainSidebarIndex,
                              initialCompactMode: false,
                              hideCollapseButton: true,
                              onItemSelected: (index) {
                                setState(() {
                                  mainSidebarIndex = index;
                                  _closeMobileSidebar();
                                });
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
                          ),
                        ),
                      ),
                    ],
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
