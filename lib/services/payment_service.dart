import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';

class RentalPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch payments for a specific user
  Stream<List<RentalPaymentModel>> getUserPayments(String userId) {
    return _firestore
        .collection('rentalPayments')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RentalPaymentModel.fromDoc(doc)).toList());
  }

  /// Add a new payment
  Future<void> addPayment(RentalPaymentModel payment) async {
    final docRef = _firestore.collection('rentalPayments').doc();
    await docRef.set(payment.toMap());
  }

  /// Confirm a payment
  Future<void> confirmPayment(String paymentId) async {
    await _firestore
        .collection('rentalPayments')
        .doc(paymentId)
        .update({'confirmed': true});
  }

  /// Fetch all payments for admin
  Stream<List<RentalPaymentModel>> getAllPaymentsStream() {
    return _firestore
        .collection('rentalPayments')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RentalPaymentModel.fromDoc(doc)).toList());
  }
}

/// ✅ Riverpod provider
final rentalPaymentServiceProvider =
    Provider<RentalPaymentService>((ref) => RentalPaymentService());
