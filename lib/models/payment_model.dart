import 'package:cloud_firestore/cloud_firestore.dart';

class RentalPaymentModel {
  final String id;
  final String userId;
  final String shopId;
  final String paymentMethod; // 'MoMo' | 'Cash'
  final int monthsPaid;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool confirmed; // Admin confirms received payment

  RentalPaymentModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.paymentMethod,
    required this.monthsPaid,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.confirmed,
  });

  factory RentalPaymentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalPaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopId: data['shopId'] ?? '',
      paymentMethod: data['paymentMethod'] ?? 'Cash',
      monthsPaid: data['monthsPaid'] ?? 1,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmed: data['confirmed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopId': shopId,
      'paymentMethod': paymentMethod,
      'monthsPaid': monthsPaid,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'confirmed': confirmed,
    };
  }
}
