import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request_model.dart';
import '../../models/shop_model.dart';
import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/payment_provider.dart';
import 'payments_page.dart';

class MyRentalPage extends ConsumerWidget {
  const MyRentalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final approvedRequestsAsync = ref.watch(userApprovedRequestsProvider(user.id));
    final paymentsAsync = ref.watch(userPaymentsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Rentals"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: approvedRequestsAsync.when(
          data: (approvedRequests) {
            if (approvedRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No approved rentals yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your rental requests will appear here once approved by admin",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: approvedRequests.length,
              itemBuilder: (context, index) {
                final request = approvedRequests[index];
                return FutureBuilder<ShopModel>(
                  future: ref.read(shopServiceProvider).getShopById(request.shopId),
                  builder: (context, shopSnapshot) {
                    if (!shopSnapshot.hasData) {
                      return const Card(
                        child: ListTile(title: Text("Loading shop details...")),
                      );
                    }

                    final shop = shopSnapshot.data!;
                    
                    return paymentsAsync.when(
                      data: (payments) {
                        // Check if user has any payments for this shop
                        final shopPayments = payments.where((p) => p.shopId == shop.id).toList();
                        final hasConfirmedPayment = shopPayments.any((p) => p.confirmed);
                        final hasPendingPayment = shopPayments.any((p) => !p.confirmed);

                        return _buildRentalCard(
                          context, 
                          ref, 
                          shop, 
                          request, 
                          shopPayments,
                          hasConfirmedPayment,
                          hasPendingPayment
                        );
                      },
                      loading: () => _buildRentalCard(context, ref, shop, request, [], false, false),
                      error: (_, __) => _buildRentalCard(context, ref, shop, request, [], false, false),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text("Error loading rentals: $error"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRentalCard(
    BuildContext context,
    WidgetRef ref,
    ShopModel shop,
    RentalRequestModel request,
    List<RentalPaymentModel> payments,
    bool hasConfirmedPayment,
    bool hasPendingPayment,
  ) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              hasConfirmedPayment 
                  ? Colors.green.withOpacity(0.1)
                  : hasPendingPayment
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
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
              // Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasConfirmedPayment 
                          ? Colors.green
                          : hasPendingPayment
                              ? Colors.orange
                              : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasConfirmedPayment 
                          ? 'ACTIVE RENTAL'
                          : hasPendingPayment
                              ? 'PAYMENT PENDING'
                              : 'APPROVED - PAY NOW',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Approved: ${request.updatedAt.day}/${request.updatedAt.month}/${request.updatedAt.year}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shop Image
              if (shop.images.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      shop.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.store, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Shop Details
              Row(
                children: [
                  Icon(Icons.store, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    shop.number,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.square_foot, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text("Size: ${shop.size}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  Icon(Icons.layers, color: Colors.purple[600], size: 20),
                  const SizedBox(width: 8),
                  Text("Floor: ${shop.floor}", style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[600], size: 24),
                  Text(
                    "\$${shop.price}/month",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              // Payment History
              if (payments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  "Payment History",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...payments.take(2).map((payment) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        payment.confirmed ? Icons.check_circle : Icons.pending,
                        color: payment.confirmed ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${payment.monthsPaid} month(s) - \$${payment.amount}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        payment.confirmed ? "Confirmed" : "Pending",
                        style: TextStyle(
                          fontSize: 12,
                          color: payment.confirmed ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              if (hasConfirmedPayment) ...[
                // Show payment history and next due date
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            "Rental Active",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (payments.isNotEmpty)
                        Text(
                          "Next payment due: ${_getNextDueDate(payments)}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TenantPaymentPage(shop: shop),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.payment),
                    label: const Text("Make Another Payment", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ] else if (hasPendingPayment) ...[
                // Show pending payment status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending, color: Colors.orange[600]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Payment submitted - waiting for admin approval",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Show pay now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TenantPaymentPage(shop: shop),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.payment, size: 24),
                    label: const Text(
                      "PAY NOW",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getNextDueDate(List<RentalPaymentModel> payments) {
    if (payments.isEmpty) return "Unknown";
    
    final latestPayment = payments.reduce((a, b) => 
        a.endDate.isAfter(b.endDate) ? a : b);
    
    final nextDue = latestPayment.endDate.add(const Duration(days: 1));
    return "${nextDue.day}/${nextDue.month}/${nextDue.year}";
  }
}
