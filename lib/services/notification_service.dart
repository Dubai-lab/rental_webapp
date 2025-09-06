import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/shop_model.dart';
import '../models/request_model.dart';
import 'payment_service.dart';
import 'shop_service.dart';
import 'request_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get notifications for a specific user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDoc(doc))
            .toList());
  }

  /// Get unread notification count for a user
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    final docRef = _firestore.collection('notifications').doc();
    await docRef.set(notification.copyWith(id: docRef.id).toMap());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Create rent due notification
  Future<void> createRentDueNotification({
    required String userId,
    required String shopId,
    required String shopNumber,
    required DateTime dueDate,
    required double amount,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      shopId: shopId,
      type: 'rent_due',
      title: 'Rent Payment Due',
      message: 'Your rent for shop $shopNumber is due on ${_formatDate(dueDate)}. Amount: \$${amount.toStringAsFixed(2)}',
      isRead: false,
      dueDate: dueDate,
      amount: amount,
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }

  /// Create payment confirmation notification
  Future<void> createPaymentConfirmedNotification({
    required String userId,
    required String shopId,
    required String shopNumber,
    required double amount,
    required int monthsPaid,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      shopId: shopId,
      type: 'payment_confirmed',
      title: 'Payment Confirmed',
      message: 'Your payment of \$${amount.toStringAsFixed(2)} for $monthsPaid month(s) rent of shop $shopNumber has been confirmed.',
      isRead: false,
      dueDate: DateTime.now(),
      amount: amount,
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }

  /// Create rental request approved notification
  Future<void> createRequestApprovedNotification({
    required String userId,
    required String shopId,
    required String shopNumber,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      shopId: shopId,
      type: 'request_approved',
      title: 'Rental Request Approved',
      message: 'Congratulations! Your rental request for shop $shopNumber has been approved. You can now make your first payment.',
      isRead: false,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }

  /// Check and create rent due notifications for all active tenants
  Future<void> checkAndCreateRentDueNotifications(
    RentalRequestService requestService,
    RentalPaymentService paymentService,
    ShopService shopService,
  ) async {
    try {
      // Get all approved requests (active tenants)
      final approvedRequests = await requestService.getApprovedRequests().first;

      for (final request in approvedRequests) {
        // Get user's payments for this shop
        final payments = await paymentService.getUserPayments(request.userId).first;
        final shopPayments = payments.where((p) => p.shopId == request.shopId && p.confirmed).toList();

        if (shopPayments.isNotEmpty) {
          // Find the latest payment
          final latestPayment = shopPayments.reduce((a, b) => 
              a.endDate.isAfter(b.endDate) ? a : b);

          // Calculate next due date (day after latest payment ends)
          final nextDueDate = latestPayment.endDate.add(const Duration(days: 1));
          final now = DateTime.now();

          // Check if rent is due within 7 days or overdue
          final daysUntilDue = nextDueDate.difference(now).inDays;

          if (daysUntilDue <= 7 && daysUntilDue >= -30) { // Due within 7 days or up to 30 days overdue
            // Check if we already sent a notification for this due date
            final existingNotifications = await _firestore
                .collection('notifications')
                .where('userId', isEqualTo: request.userId)
                .where('shopId', isEqualTo: request.shopId)
                .where('type', isEqualTo: 'rent_due')
                .where('dueDate', isEqualTo: nextDueDate)
                .get();

            if (existingNotifications.docs.isEmpty) {
              // Get shop details
              final shop = await shopService.getShopById(request.shopId);

              // Create rent due notification
              await createRentDueNotification(
                userId: request.userId,
                shopId: request.shopId,
                shopNumber: shop.number,
                dueDate: nextDueDate,
                amount: shop.price,
              );
            }
          }
        } else {
          // No payments yet, create initial payment reminder
          final shop = await shopService.getShopById(request.shopId);
          final dueDate = request.updatedAt.add(const Duration(days: 7)); // 7 days after approval

          // Check if we already sent initial payment notification
          final existingNotifications = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: request.userId)
              .where('shopId', isEqualTo: request.shopId)
              .where('type', isEqualTo: 'rent_due')
              .get();

          if (existingNotifications.docs.isEmpty) {
            await createRentDueNotification(
              userId: request.userId,
              shopId: request.shopId,
              shopNumber: shop.number,
              dueDate: dueDate,
              amount: shop.price,
            );
          }
        }
      }
    } catch (e) {
      print('Error checking rent due notifications: $e');
    }
  }

  /// Delete old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final oldNotifications = await _firestore
        .collection('notifications')
        .where('createdAt', isLessThan: thirtyDaysAgo)
        .get();

    final batch = _firestore.batch();
    for (var doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Riverpod provider
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());