import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_model.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all shops
  Stream<List<ShopModel>> getShops() {
    return _firestore.collection('shops').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ShopModel.fromDoc(doc)).toList());
  }

  /// Add new shop
  Future<void> addShop(ShopModel shop) async {
    final docRef = _firestore.collection('shops').doc();
    await docRef.set(shop.copyWith(id: docRef.id).toMap());
  }

  /// Update existing shop
  Future<void> updateShop(ShopModel shop) async {
    await _firestore.collection('shops').doc(shop.id).update(shop.toMap());
  }

  /// Delete shop
  Future<void> deleteShop(String id) async {
    await _firestore.collection('shops').doc(id).delete();
  }

  /// Fetch a single shop by ID
  Future<ShopModel> getShopById(String id) async {
    final doc = await _firestore.collection('shops').doc(id).get();
    return ShopModel.fromDoc(doc);
  }
}

/// ✅ Riverpod provider for ShopService
final shopServiceProvider = Provider<ShopService>((ref) => ShopService());
