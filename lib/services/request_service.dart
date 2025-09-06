import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_webapp/models/request_model.dart';

class RentalRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all rental requests as a stream
  Stream<List<RentalRequestModel>> getRequests() {
    return _firestore.collection('rental_requests').orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => RentalRequestModel.fromDoc(doc)).toList(),
    );
  }

  /// Add a new request
  Future<void> addRequest(RentalRequestModel request) async {
    final docRef = _firestore.collection('rental_requests').doc();
    await docRef.set(request.copyWith(id: docRef.id).toMap());
  }

  /// Update a request (approve/reject)
  Future<void> updateRequest(RentalRequestModel request) async {
    await _firestore.collection('rental_requests').doc(request.id).update(request.toMap());
  }

  /// Delete a request
  Future<void> deleteRequest(String id) async {
    await _firestore.collection('rental_requests').doc(id).delete();
  }

  /// Get all approved requests (active tenants)
  Stream<List<RentalRequestModel>> getApprovedRequests() {
    return _firestore
        .collection('rental_requests')
        .where('status', isEqualTo: 'approved')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RentalRequestModel.fromDoc(doc)).toList());
  }

  /// Get user's approved requests (their rentals)
  Stream<List<RentalRequestModel>> getUserApprovedRequests(String userId) {
    return _firestore
        .collection('rental_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RentalRequestModel.fromDoc(doc)).toList());
  }
}

/// Provider for Riverpod
final rentalRequestServiceProvider = Provider<RentalRequestService>((ref) => RentalRequestService());
