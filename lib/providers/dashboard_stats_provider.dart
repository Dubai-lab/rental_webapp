import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './shop_provider.dart';

final shopStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(shopsProvider.stream).map((shops) {
    return {
      'total': shops.length,
      'available': shops.where((shop) => shop.status == 'available').length,
      'occupied': shops.where((shop) => shop.status == 'occupied').length,
      'pending': shops.where((shop) => shop.status == 'pending').length,
    };
  });
});

final tenantCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'user')
      .snapshots()
      .map((snap) => snap.docs.length);
});

final dashboardStatsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(shopsProvider.stream).map((shops) => {
    'totalShops': shops.length,
    'availableShops': shops.where((shop) => shop.status == 'available').length,
    'occupiedShops': shops.where((shop) => shop.status == 'occupied').length,
    'pendingShops': shops.where((shop) => shop.status == 'pending').length,
  });
});