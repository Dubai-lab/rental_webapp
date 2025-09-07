import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;

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

    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<List<RentalPaymentModel>> filteredPayments = ValueNotifier([]);

    // Initialize with all payments
    paymentService.getAllPaymentsStream().first.then((payments) {
      filteredPayments.value = payments;
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Rental Payments")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by tenant name or shop number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                final payments = await paymentService.getAllPaymentsStream().first;
                final filtered = await _filterPayments(payments, shopService, authService, value);
                filteredPayments.value = filtered;
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<RentalPaymentModel>>(
              valueListenable: filteredPayments,
              builder: (context, payments, _) {
                if (payments.isEmpty) {
                  return const Center(child: Text("No payments found."));
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
                                  "Shop: ${shop?.number ?? 'Unknown'}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text("User: ${user?.name ?? 'Unknown'}"),
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
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _printReceipt(context, payment, shop, user),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                        child: const Text("Print Receipt"),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _printReceipt(context, payment, shop, user),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                        child: const Text("Print Receipt"),
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
          ),
        ],
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

  /// Filter payments based on search query
  Future<List<RentalPaymentModel>> _filterPayments(
    List<RentalPaymentModel> payments,
    shop_service.ShopService shopService,
    auth_service.AuthService authService,
    String query,
  ) async {
    if (query.isEmpty) return payments;

    final searchLower = query.toLowerCase();
    final filtered = <RentalPaymentModel>[];

    for (final payment in payments) {
      final shop = await shopService.getShopById(payment.shopId);
      final user = await authService.getUserById(payment.userId);
      if ((user != null && user.name.toLowerCase().contains(searchLower)) ||
          (shop != null && shop.number.toLowerCase().contains(searchLower))) {
        filtered.add(payment);
      }
    }

    return filtered;
  }

  void _printReceipt(BuildContext context, RentalPaymentModel payment, ShopModel shop, UserModel user) async {
    final pdf = pw.Document();

    final font = pw.Font.times();
    final fontBold = pw.Font.timesBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rental Payment Receipt',
                  style: pw.TextStyle(font: fontBold, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Tenant: ${user.name}', style: pw.TextStyle(font: font)),
              pw.Text('Email: ${user.email}', style: pw.TextStyle(font: font)),
              pw.Text('Phone: ${user.phone}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Text('Shop Number: ${shop.number}', style: pw.TextStyle(font: font)),
              pw.Text('Shop Size: ${shop.size}', style: pw.TextStyle(font: font)),
              pw.Text('Floor: ${shop.floor}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Text('Payment Method: ${payment.paymentMethod}', style: pw.TextStyle(font: font)),
              pw.Text('Months Paid: ${payment.monthsPaid}', style: pw.TextStyle(font: font)),
              pw.Text('Amount Paid: \$${payment.amount.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
              pw.Text('Payment Date: ${payment.startDate.toString()}', style: pw.TextStyle(font: font)),
              pw.Text('Lease End Date: ${payment.endDate.toString()}', style: pw.TextStyle(font: font)),
              pw.Text('Status: ${payment.confirmed ? 'Confirmed' : 'Pending'}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Text('Thank you for your payment!',
                  style: pw.TextStyle(font: fontBold, fontSize: 16)),
            ],
          );
        },
      ),
    );

    if (kIsWeb) {
      // For web, open PDF in new tab
      final pdfData = await pdf.save();
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    }
  }
}
