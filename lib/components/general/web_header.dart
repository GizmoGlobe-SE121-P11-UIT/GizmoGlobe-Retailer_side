import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class WebHeader extends StatelessWidget {
  final int unreadChats;
  final VoidCallback? onChatPressed;
  final List<Widget>? actions;
  final bool isSidebarCompact;

  const WebHeader({
    super.key,
    this.unreadChats = 0,
    this.onChatPressed,
    this.actions,
    this.isSidebarCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show on web platform
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Logo/Brand section
            InkWell(
              onTap: () {
                // Navigate to main screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/main',
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'lib/GIzmoGlobe.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Spacer
            const Expanded(child: SizedBox()),

            // Actions section
            Row(
              children: [
                // Chat button with notification badge
                Stack(
                  children: [
                    IconButton(
                      onPressed: onChatPressed ??
                          () {
                            Navigator.pushNamed(
                              context,
                              '/chat',
                            );
                          },
                      icon: Icon(
                        Icons.chat_rounded,
                        color: colorScheme.onSurface,
                      ),
                      tooltip: 'Chat',
                    ),
                    if (unreadChats > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadChats > 99 ? '99+' : unreadChats.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                // Custom actions
                if (actions != null) ...actions!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper widget that adds the web header to any screen when running on web
class WebHeaderWrapper extends StatelessWidget {
  final Widget child;
  final int unreadChats;
  final VoidCallback? onChatPressed;
  final List<Widget>? actions;
  final bool isSidebarCompact;

  const WebHeaderWrapper({
    super.key,
    required this.child,
    this.unreadChats = 0,
    this.onChatPressed,
    this.actions,
    this.isSidebarCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // On mobile, just return the child without header
      return child;
    }

    return Column(
      children: [
        WebHeader(
          unreadChats: unreadChats,
          onChatPressed: onChatPressed,
          actions: actions,
          isSidebarCompact: isSidebarCompact,
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// A scaffold wrapper that automatically includes the web header
class WebScaffold extends StatelessWidget {
  final Widget body;
  final int unreadChats;
  final VoidCallback? onChatPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool isSidebarCompact;

  const WebScaffold({
    super.key,
    required this.body,
    this.unreadChats = 0,
    this.onChatPressed,
    this.actions,
    this.backgroundColor,
    this.isSidebarCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // On mobile, use regular Scaffold
      return Scaffold(
        backgroundColor: backgroundColor,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      body: WebHeaderWrapper(
        unreadChats: unreadChats,
        onChatPressed: onChatPressed,
        actions: actions,
        isSidebarCompact: isSidebarCompact,
        child: body,
      ),
    );
  }
}
