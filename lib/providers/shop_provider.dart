import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_model.dart';
import '../services/shop_service.dart';

final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

final shopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final service = ref.read(shopServiceProvider);
  return service.getShops();
});
