import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_webapp/models/request_model.dart';
import 'package:rental_webapp/services/request_service.dart';

final rentalRequestServiceProvider = Provider<RentalRequestService>((ref) {
  return RentalRequestService();
});

final rentalRequestsProvider = StreamProvider<List<RentalRequestModel>>((ref) {
  final service = ref.read(rentalRequestServiceProvider);
  return service.getRequests();
});

// Provider to get user's approved requests (their rentals)
final userApprovedRequestsProvider = StreamProvider.family<List<RentalRequestModel>, String>((ref, userId) {
  final service = ref.read(rentalRequestServiceProvider);
  return service.getUserApprovedRequests(userId);
});
