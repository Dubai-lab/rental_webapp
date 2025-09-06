import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_webapp/models/payment_model.dart';
import 'package:rental_webapp/services/payment_service.dart';

final rentalPaymentServiceProvider = Provider<RentalPaymentService>((ref) {
  return RentalPaymentService();
});

final userPaymentsProvider = StreamProvider.family<List<RentalPaymentModel>, String>((ref, userId) {
  final service = ref.read(rentalPaymentServiceProvider);
  return service.getUserPayments(userId);
});
