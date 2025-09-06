import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRequestModel {
  final String id;
  final String shopId;
  final String userId;
  final String status; // "pending" | "approved" | "rejected"
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalRequestModel({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalRequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalRequestModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      message: data['message'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// New factory fromMap to fix service usage
  factory RentalRequestModel.fromMap(Map<String, dynamic> data, String id) {
    return RentalRequestModel(
      id: id,
      shopId: data['shopId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      message: data['message'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'status': status,
      'message': message,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RentalRequestModel copyWith({
    String? id,
    String? shopId,
    String? userId,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RentalRequestModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
