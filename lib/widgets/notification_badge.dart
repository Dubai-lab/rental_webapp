import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../features/user/notifications_page.dart';

class NotificationBadge extends ConsumerWidget {
  final Color? iconColor;
  final double? iconSize;

  const NotificationBadge({
    super.key,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return IconButton(
        onPressed: null,
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Colors.grey,
          size: iconSize,
        ),
      );
    }

    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(user.id));

    return unreadCountAsync.when(
      data: (unreadCount) => Stack(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
            icon: Icon(
              unreadCount > 0 
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: iconColor ?? (unreadCount > 0 ? Colors.orange : Colors.grey),
              size: iconSize,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
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
      loading: () => IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationsPage(),
            ),
          );
        },
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Colors.grey,
          size: iconSize,
        ),
      ),
      error: (_, __) => IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationsPage(),
            ),
          );
        },
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Colors.grey,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Simplified notification icon for use in bottom navigation
class NotificationIcon extends ConsumerWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Icon(Icons.notifications_outlined);
    }

    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(user.id));

    return unreadCountAsync.when(
      data: (unreadCount) => Stack(
        children: [
          Icon(
            unreadCount > 0 
                ? Icons.notifications_active
                : Icons.notifications_outlined,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      loading: () => const Icon(Icons.notifications_outlined),
      error: (_, __) => const Icon(Icons.notifications_outlined),
    );
  }
}