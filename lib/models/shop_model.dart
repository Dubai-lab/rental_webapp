import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String number;
  final int floor;
  final String size; // e.g., "25 sqm"
  final double price;
  final String status; // "available" | "pending" | "occupied"
  final String? tenantId;
  final List<String> images;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.size,
    required this.price,
    required this.status,
    this.tenantId,
    required this.images,
    required this.createdAt,
  });

  factory ShopModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopModel(
      id: doc.id,
      number: data['number'] ?? '',
      floor: data['floor'] ?? 0,
      size: data['size'] ?? '',
      price: (data['price'] as num).toDouble(),
      status: data['status'] ?? 'available',
      tenantId: data['tenantId'],
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'floor': floor,
      'size': size,
      'price': price,
      'status': status,
      'tenantId': tenantId,
      'images': images,
      'createdAt': createdAt,
    };
  }

  ShopModel copyWith({
    String? id,
    String? number,
    int? floor,
    String? size,
    double? price,
    String? status,
    String? tenantId,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      size: size ?? this.size,
      price: price ?? this.price,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
