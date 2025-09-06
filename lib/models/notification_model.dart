import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String shopId;
  final String type; // "rent_due", "payment_confirmed", "request_approved", etc.
  final String title;
  final String message;
  final bool isRead;
  final DateTime dueDate; // For rent due notifications
  final double? amount; // For payment-related notifications
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.dueDate,
    this.amount,
    required this.createdAt,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopId: data['shopId'] ?? '',
      type: data['type'] ?? 'general',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.now(),
      amount: data['amount']?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopId': shopId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'dueDate': dueDate,
      'amount': amount,
      'createdAt': createdAt,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? dueDate,
    double? amount,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to check if notification is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate) && type == 'rent_due';

  // Helper method to get days until due
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  // Helper method to format due date
  String get formattedDueDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }
}