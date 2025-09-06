import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/shop_service.dart' as shop_service;
import '../../services/auth_service.dart' as auth_service;
import '../../services/payment_service.dart' as payment_service;

import '../../models/payment_model.dart';
import '../../models/shop_model.dart';
import '../../models/user_model.dart';


class AdminPaymentPage extends ConsumerWidget {
  const AdminPaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentService = ref.read(payment_service.rentalPaymentServiceProvider);
final shopService = ref.read(shop_service.shopServiceProvider);
final authService = ref.read(auth_service.authServiceProvider);


    return Scaffold(
      appBar: AppBar(title: const Text("Rental Payments")),
      body: StreamBuilder<List<RentalPaymentModel>>(
        stream: paymentService.getAllPaymentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const Center(child: Text("No payments yet."));
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];

              return FutureBuilder<Map<String, dynamic>>(
                future: _getShopAndUser(shopService, authService, payment),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return const Card(
                      child: ListTile(title: Text("Loading...")),
                    );
                  }

                  final data = dataSnapshot.data!;
                  final ShopModel shop = data['shop'];
                  final UserModel user = data['user'];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shop: ${shop.number}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text("User: ${user.name}"),
                          Text("Payment Method: ${payment.paymentMethod}"),
                          Text("Months Paid: ${payment.monthsPaid}"),
                          Text("Amount: \$${payment.amount}"),
                          Text(
                            "Period: ${payment.startDate.toLocal().toString().split(' ')[0]} - ${payment.endDate.toLocal().toString().split(' ')[0]}"
                          ),
                          Text(
                            "Status: ${payment.confirmed ? 'Confirmed' : 'Pending'}"
                          ),
                          if (!payment.confirmed)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await paymentService.confirmPayment(payment.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Payment confirmed")
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Helper to fetch shop and user details
  Future<Map<String, dynamic>> _getShopAndUser(
    shop_service.ShopService shopService,
    auth_service.AuthService authService,
    RentalPaymentModel payment
  ) async {
    final shop = await shopService.getShopById(payment.shopId);
    final user = await authService.getUserById(payment.userId) ??
        UserModel(
          id: '',
          name: 'Unknown',
          email: '',
          phone: '',
          role: 'user',
          createdAt: DateTime.now(),
        );
    return {'shop': shop, 'user': user};
  }
}
