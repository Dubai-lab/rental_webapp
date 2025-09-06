import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request_model.dart';
import '../../models/shop_model.dart';
import '../../models/user_model.dart';
import '../../models/payment_model.dart';
import '../../providers/request_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';

// Provider to get all approved requests (active tenants)
final activeTenantsProvider = StreamProvider<List<RentalRequestModel>>((ref) {
  final service = ref.read(rentalRequestServiceProvider);
  return service.getApprovedRequests();
});

class TenantPage extends ConsumerWidget {
  const TenantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTenantsAsync = ref.watch(activeTenantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenants Management"),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(activeTenantsProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: activeTenantsAsync.when(
          data: (tenants) {
            if (tenants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No active tenants yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Approved rental requests will show tenants here",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.purple.withOpacity(0.1), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tenants.length}",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              Text(
                                "Active Tenants",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tenants List
                Expanded(
                  child: ListView.builder(
                    itemCount: tenants.length,
                    itemBuilder: (context, index) {
                      final tenant = tenants[index];
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getTenantDetails(ref, tenant),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Card(
                              child: ListTile(title: Text("Loading tenant details...")),
                            );
                          }

                          final data = snapshot.data!;
                          final ShopModel shop = data['shop'];
                          final UserModel user = data['user'];
                          final List<RentalPaymentModel> payments = data['payments'];

                          return _buildTenantCard(context, ref, tenant, shop, user, payments);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text("Error loading tenants: $error"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(activeTenantsProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenantCard(
    BuildContext context,
    WidgetRef ref,
    RentalRequestModel tenant,
    ShopModel shop,
    UserModel user,
    List<RentalPaymentModel> payments,
  ) {
    final hasActivePayment = payments.any((p) => p.confirmed);
    final totalPaid = payments.where((p) => p.confirmed).fold<double>(0, (sum, p) => sum + p.amount);
    final lastPayment = payments.isNotEmpty 
        ? payments.reduce((a, b) => a.startDate.isAfter(b.startDate) ? a : b)
        : null;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              hasActivePayment 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple[600],
                    radius: 25,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasActivePayment ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasActivePayment ? 'ACTIVE' : 'PENDING PAYMENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shop Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Shop: ${shop.number}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.square_foot, color: Colors.orange[600], size: 18),
                        const SizedBox(width: 8),
                        Text("${shop.size}"),
                        const SizedBox(width: 20),
                        Icon(Icons.layers, color: Colors.purple[600], size: 18),
                        const SizedBox(width: 8),
                        Text("Floor ${shop.floor}"),
                        const SizedBox(width: 20),
                        Icon(Icons.attach_money, color: Colors.green[600], size: 18),
                        const SizedBox(width: 8),
                        Text("\$${shop.price}/month"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Summary
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "\$${totalPaid.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text(
                            "Total Paid",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${payments.where((p) => p.confirmed).fold<int>(0, (sum, p) => sum + p.monthsPaid)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            "Months Paid",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${payments.length}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const Text(
                            "Payments",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Last Payment Info
              if (lastPayment != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        lastPayment.confirmed ? Icons.check_circle : Icons.pending,
                        color: lastPayment.confirmed ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Last Payment: \$${lastPayment.amount} (${lastPayment.monthsPaid} months)",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${lastPayment.startDate.day}/${lastPayment.startDate.month}/${lastPayment.startDate.year} - ${lastPayment.paymentMethod}",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        lastPayment.confirmed ? "Confirmed" : "Pending",
                        style: TextStyle(
                          color: lastPayment.confirmed ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTenantDetails(context, user, shop, payments),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text("View Details"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showContactOptions(context, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text("Contact"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getTenantDetails(WidgetRef ref, RentalRequestModel tenant) async {
    final shopService = ref.read(shopServiceProvider);
    final authService = ref.read(authServiceProvider);
    final paymentService = ref.read(rentalPaymentServiceProvider);

    // Fetch shop details
    final shop = await shopService.getShopById(tenant.shopId);
    
    // Fetch user details
    final user = await authService.getUserById(tenant.userId) ??
        UserModel(
          id: '',
          name: 'Unknown User',
          email: '',
          phone: '',
          role: 'user',
          createdAt: DateTime.now(),
        );

    // Fetch user's payments for this shop
    final paymentsStream = paymentService.getUserPayments(tenant.userId);
    final allPayments = await paymentsStream.first;
    final shopPayments = allPayments.where((p) => p.shopId == tenant.shopId).toList();

    return {
      'shop': shop,
      'user': user,
      'payments': shopPayments,
    };
  }

  void _showTenantDetails(BuildContext context, UserModel user, ShopModel shop, List<RentalPaymentModel> payments) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${user.name} - Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Email: ${user.email}"),
              Text("Phone: ${user.phone}"),
              const SizedBox(height: 16),
              Text("Shop: ${shop.number}"),
              Text("Size: ${shop.size}"),
              Text("Floor: ${shop.floor}"),
              Text("Monthly Rent: \$${shop.price}"),
              const SizedBox(height: 16),
              const Text("Payment History:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...payments.map((payment) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "• \$${payment.amount} - ${payment.monthsPaid} months (${payment.confirmed ? 'Confirmed' : 'Pending'})",
                  style: TextStyle(
                    color: payment.confirmed ? Colors.green : Colors.orange,
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contact ${user.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(user.email),
              onTap: () {
                // TODO: Implement email functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Email: ${user.email}")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Phone"),
              subtitle: Text(user.phone),
              onTap: () {
                // TODO: Implement phone call functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Phone: ${user.phone}")),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}