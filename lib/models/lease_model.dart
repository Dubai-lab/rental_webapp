import 'package:cloud_firestore/cloud_firestore.dart';

class LeaseModel {
  final String id;
  final String shopId;
  final String tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double rent;
  final double deposit;
  final String status; // "active" | "expired" | "terminated"
  final DateTime createdAt;

  LeaseModel({
    required this.id,
    required this.shopId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.rent,
    required this.deposit,
    required this.status,
    required this.createdAt,
  });

  factory LeaseModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaseModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      rent: (data['rent'] as num).toDouble(),
      deposit: (data['deposit'] as num).toDouble(),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'tenantId': tenantId,
      'startDate': startDate,
      'endDate': endDate,
      'rent': rent,
      'deposit': deposit,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
