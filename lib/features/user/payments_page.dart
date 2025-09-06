import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../models/shop_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';

class TenantPaymentPage extends ConsumerStatefulWidget {
  final ShopModel shop;
  const TenantPaymentPage({super.key, required this.shop});

  @override
  ConsumerState<TenantPaymentPage> createState() => _TenantPaymentPageState();
}

class _TenantPaymentPageState extends ConsumerState<TenantPaymentPage> {
  String selectedMethod = 'Cash';
  int monthsToPay = 1;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Center(child: CircularProgressIndicator());

    final totalAmount = widget.shop.price * monthsToPay;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pay for ${widget.shop.number}"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Details Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.1), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: Colors.blue[600], size: 28),
                          const SizedBox(width: 12),
                          Text(
                            widget.shop.number,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (widget.shop.images.isNotEmpty)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.shop.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.store, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(Icons.square_foot, color: Colors.orange[600], size: 20),
                          const SizedBox(width: 8),
                          Text("Size: ${widget.shop.size}", style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 20),
                          Icon(Icons.layers, color: Colors.purple[600], size: 20),
                          const SizedBox(width: 8),
                          Text("Floor: ${widget.shop.floor}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green[600], size: 24),
                          Text(
                            "\$${widget.shop.price}/month",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Payment Form Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.blue[600], size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Method Selection
                    const Text(
                      "Payment Method",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedMethod = 'Cash'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedMethod == 'Cash' 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedMethod == 'Cash' 
                                      ? Colors.green 
                                      : Colors.grey.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.money,
                                    color: selectedMethod == 'Cash' 
                                        ? Colors.green 
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Cash",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedMethod == 'Cash' 
                                          ? Colors.green 
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedMethod = 'MoMo'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedMethod == 'MoMo' 
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedMethod == 'MoMo' 
                                      ? Colors.orange 
                                      : Colors.grey.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    color: selectedMethod == 'MoMo' 
                                        ? Colors.orange 
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "MoMo MTN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedMethod == 'MoMo' 
                                          ? Colors.orange 
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Months to Pay
                    const Text(
                      "Number of Months",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: TextFormField(
                        initialValue: monthsToPay.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Months to Pay",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        onChanged: (val) => setState(() => monthsToPay = int.tryParse(val) ?? 1),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // MoMo Instructions
                    if (selectedMethod == 'MoMo') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  "MoMo Payment Instructions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text("1. Dial *156# on your MTN phone"),
                            const SizedBox(height: 4),
                            const Text("2. Select 'Send Money'"),
                            const SizedBox(height: 4),
                            Text("3. Send \$${totalAmount.toStringAsFixed(2)} to: 088-054-5981"),
                            const SizedBox(height: 4),
                            const Text("4. Use your name as reference"),
                            const SizedBox(height: 4),
                            const Text("5. Click 'Submit Payment' below after sending"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Total Amount Display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Amount",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "$monthsToPay month(s) × \$${widget.shop.price}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Text(
                            "\$${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submitPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isSubmitting 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, size: 24),
                        label: Text(
                          isSubmitting ? "Submitting..." : "Submit Payment",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    setState(() => isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final now = DateTime.now();
      final endDate = now.add(Duration(days: 30 * monthsToPay));

      final payment = RentalPaymentModel(
        id: '',
        userId: user.id,
        shopId: widget.shop.id,
        paymentMethod: selectedMethod,
        monthsPaid: monthsToPay,
        amount: widget.shop.price * monthsToPay,
        startDate: now,
        endDate: endDate,
        confirmed: false,
      );

      await ref.read(rentalPaymentServiceProvider).addPayment(payment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Payment request submitted successfully! Admin will review and confirm.",
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("Error submitting payment: $e")),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }
}
