import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';

class ManageShopPage extends ConsumerWidget {
  const ManageShopPage({super.key});

  final String storageBucket = 'rentalapp001-6da48.firebasestorage.app';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Shops"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddOrEditDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: shopsAsync.when(
          data: (shops) {
            if (shops.isEmpty) {
              return const Center(child: Text("No shops added yet."));
            }
            return ListView.builder(
              itemCount: shops.length,
              itemBuilder: (_, index) => _shopCard(context, ref, shops[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _shopCard(BuildContext context, WidgetRef ref, ShopModel shop) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: shop.images.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: shop.images.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            shop.images[i],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.store, size: 50, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(shop.number,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text("${shop.size} | Floor ${shop.floor}"),
            Text("\$${shop.price}/month",
                style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _showAddOrEditDialog(context, ref, shop: shop),
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () =>
                      ref.read(shopServiceProvider).deleteShop(shop.id),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddOrEditDialog(BuildContext context, WidgetRef ref,
      {ShopModel? shop}) async {
    final _formKey = GlobalKey<FormState>();
    String number = shop?.number ?? '';
    String size = shop?.size ?? '';
    String floor = shop?.floor.toString() ?? '';
    String price = shop?.price.toString() ?? '';
    String status = shop?.status ?? 'available';
    List<XFile> newImages = [];
    List<String> existingImages = shop?.images ?? [];

    final picker = ImagePicker();

    Future<void> _pickImages() async {
      final picked = await picker.pickMultiImage(imageQuality: 70);
      if (picked.isNotEmpty) newImages.addAll(picked);
    }

    Future<List<String>> _uploadImages() async {
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://$storageBucket');
      List<String> urls = [];

      for (var file in newImages) {
        final refStorage = storage
            .ref()
            .child('shops/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          await refStorage.putData(bytes);
        } else {
          await refStorage.putFile(File(file.path));
        }
        urls.add(await refStorage.getDownloadURL());
      }

      return [...existingImages, ...urls];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                shop == null ? "Add New Shop" : "Edit Shop Details",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: number,
                          decoration: InputDecoration(
                            labelText: "Shop Number",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => number = val,
                          validator: (val) =>
                              val!.isEmpty ? "Shop number required" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: size,
                          decoration: InputDecoration(
                            labelText: "Size",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => size = val,
                          validator: (val) => val!.isEmpty ? "Size required" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: floor,
                          decoration: InputDecoration(
                            labelText: "Floor",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => floor = val,
                          validator: (val) => val!.isEmpty ? "Floor required" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: price,
                          decoration: InputDecoration(
                            labelText: "Price",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => price = val,
                          validator: (val) => val!.isEmpty ? "Price required" : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: status,
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('Available')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                          ],
                          onChanged: (val) => status = val!,
                          decoration: InputDecoration(
                            labelText: "Status",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text("Add Images"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (existingImages.isNotEmpty || newImages.isNotEmpty)
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              children: [
                                ...existingImages.map((url) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                                      ),
                                    )),
                                ...newImages.map((xfile) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: kIsWeb
                                            ? Image.network(xfile.path, width: 80, height: 80, fit: BoxFit.cover)
                                            : Image.file(File(xfile.path), width: 80, height: 80, fit: BoxFit.cover),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final uploadedImages = await _uploadImages();
                        final shopId = shop?.id.isNotEmpty == true
                            ? shop!.id
                            : FirebaseFirestore.instance.collection('shops').doc().id;

                        final shopData = ShopModel(
                          id: shopId,
                          number: number,
                          floor: int.tryParse(floor) ?? 0,
                          size: size,
                          price: double.tryParse(price) ?? 0.0,
                          status: status,
                          images: uploadedImages,
                          tenantId: shop?.tenantId,
                          createdAt: shop?.createdAt ?? DateTime.now(),
                        );

                        if (shop == null) {
                          await ref.read(shopServiceProvider).addShop(shopData);
                        } else {
                          await ref.read(shopServiceProvider).updateShop(shopData);
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
