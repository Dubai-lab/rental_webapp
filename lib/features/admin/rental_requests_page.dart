import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request_model.dart';
import '../../models/shop_model.dart';
import '../../models/user_model.dart';
import '../../providers/request_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';

class RentalRequestsPage extends ConsumerWidget {
  const RentalRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(rentalRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Rental Requests")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const Center(child: Text("No rental requests yet."));
            }

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getShopAndUser(ref, request),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Card(
                        child: ListTile(title: Text("Loading...")),
                      );
                    }

                    final data = snapshot.data!;
                    final ShopModel shop = data['shop'];
                    final UserModel user = data['user'];

                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              request.status == 'pending' 
                                  ? Colors.orange.withOpacity(0.1)
                                  : request.status == 'approved'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: request.status == 'pending'
                                          ? Colors.orange
                                          : request.status == 'approved'
                                              ? Colors.green
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      request.status.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.store, color: Colors.blue[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Shop: ${shop.number}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.green[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text("Requested by: ${user.name}",
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text("${user.email}",
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                ],
                              ),
                              if (request.message != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.message, color: Colors.blue[600], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text("${request.message}",
                                          style: const TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (request.status == 'pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () async {
                                          await _updateRequestStatus(
                                              ref, request, 'approved');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Request approved successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text("Approve"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () async {
                                          await _updateRequestStatus(
                                              ref, request, 'rejected');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Request rejected'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.cancel),
                                        label: const Text("Reject"),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text("Error loading requests: $error")),
        ),
      ),
    );
  }

  /// Helper to get Shop and User data
  Future<Map<String, dynamic>> _getShopAndUser(
      WidgetRef ref, RentalRequestModel request) async {
    final shopService = ref.read(shopServiceProvider);
    final authService = ref.read(authServiceProvider);

    // Fetch shop
    ShopModel shop = await shopService.getShopById(request.shopId);
    // Fetch user
    UserModel? user = await authService.getUserById(request.userId);

    return {
      'shop': shop,
      'user': user ??
          UserModel(
            id: '',
            name: 'Unknown',
            email: '',
            phone: '',
            role: 'user',
            createdAt: DateTime.now(),
          ),
    };
  }

  /// Update request status
  Future<void> _updateRequestStatus(
      WidgetRef ref, RentalRequestModel request, String status) async {
    final service = ref.read(rentalRequestServiceProvider);
    await service.updateRequest(request.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    ));
  }
}
