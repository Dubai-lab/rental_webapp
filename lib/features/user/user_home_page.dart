import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_webapp/config/app_router.dart';
import 'package:animations/animations.dart';
import '../chat/chat_page.dart';
import '../../models/shop_model.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/notification_badge.dart';

final shopsProvider = StreamProvider<List<ShopModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('shops')
      .where('status', isEqualTo: 'available')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ShopModel.fromDoc(doc)).toList());
});

class UserHomePage extends ConsumerWidget {
  UserHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Shops"),
        actions: const [NotificationBadge()],
      ),
      drawer: Drawer(
  child: Column(
    children: [
      UserAccountsDrawerHeader(
        accountName: Text(user?.name ?? ""),
        accountEmail: Text(user?.email ?? ""),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "?",
            style: const TextStyle(fontSize: 24, color: Colors.red),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.shopping_bag),
        title: const Text("My Rentals"),
        onTap: () {
          Navigator.pop(context); // Close drawer
          AppRouter.goToMyRentals(context); // Navigate to My Rentals page
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Profile"),
        onTap: () {
          Navigator.pop(context); // Close drawer
          AppRouter.goToUserProfile(context); // Navigate to My Rentals page
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Logout"),
        onTap: () async {
          await ref.read(currentUserProvider.notifier).logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ],
  ),
),

      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const ChatPage(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          backgroundColor: Colors.blue,
          child: const Badge(
            label: Text("New"),
            child: Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: shopsAsync.when(
          data: (shops) {
            if (shops.isEmpty) {
              return const Center(child: Text("No shops available."));
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(shopsProvider);
              },
              child: ListView.builder(
                itemCount: shops.length,
                itemBuilder: (_, index) => _shopCard(shops[index], context),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text("Error loading shops: $error")),
        ),
      ),
    );
  }

  Widget _shopCard(ShopModel shop, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: shop.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PageView(
                              children: shop.images
                                  .map((img) => Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.broken_image,
                                                size: 50, color: Colors.grey),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[100]!, Colors.blue[50]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.store, size: 60, color: Colors.blue),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AVAILABLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.store, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    shop.number,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.square_foot, color: Colors.orange[600], size: 18),
                  const SizedBox(width: 8),
                  Text("${shop.size}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(width: 20),
                  Icon(Icons.layers, color: Colors.purple[600], size: 18),
                  const SizedBox(width: 8),
                  Text("Floor ${shop.floor}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[600], size: 20),
                  Text(
                    "\$${shop.price}/month",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopDetailPage(shop: shop),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: const Text(
                    "View & Request Rent",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopDetailPage extends ConsumerWidget {
  final ShopModel shop;
  const ShopDetailPage({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(shop.number)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: shop.images.isNotEmpty
                  ? PageView(
                      children: shop.images
                          .map((img) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(img,
                                    fit: BoxFit.cover, width: double.infinity),
                              ))
                          .toList(),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Icon(Icons.store, size: 50)),
                    ),
            ),
            const SizedBox(height: 16),
            Text(shop.number,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text("Size: ${shop.size}"),
            Text("Floor: ${shop.floor}"),
            Text("Price: \$${shop.price}/month",
                style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login first')));
                  return;
                }

                try {
                  // Create rental request using the proper model and service
                  final request = RentalRequestModel(
                    id: '', // Will be set by Firestore
                    shopId: shop.id,
                    userId: user.id,
                    status: 'pending',
                    message: 'Request to rent ${shop.number}',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  // Use the service to add the request
                  await ref.read(rentalRequestServiceProvider).addRequest(request);

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rental request sent successfully!')));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending request: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("Request Rent"),
            ),
          ],
        ),
      ),
    );
  }
}
