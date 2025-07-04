import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupportUsScreen extends StatefulWidget {
  const SupportUsScreen({Key? key}) : super(key: key);

  @override
  State<SupportUsScreen> createState() => _SupportUsScreenState();
}

class _SupportUsScreenState extends State<SupportUsScreen> {
  final List<Map<String, dynamic>> _donationAmounts = [
    {'amount': 5, 'label': '\$5'},
    {'amount': 10, 'label': '\$10'},
    {'amount': 20, 'label': '\$20'},
    {'amount': 50, 'label': '\$50'},
  ];

  int? _selectedAmount;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Support Our Project',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your support helps us maintain and improve the Digital Certificate Repository platform.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Donation Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _donationAmounts.map((amount) {
                return ChoiceChip(
                  label: Text(amount['label']),
                  selected: _selectedAmount == amount['amount'],
                  onSelected: (selected) {
                    setState(() {
                      _selectedAmount = selected ? amount['amount'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedAmount == null || _isProcessing
                  ? null
                  : () => _handlePayment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Donate Now', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Secure payment powered by Stripe',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    if (_selectedAmount == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Create payment intent
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4242/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': _selectedAmount! * 100, // Amount in cents
          'currency': 'myr',
        }),
      );

      final jsonResponse = json.decode(response.body);

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['clientSecret'],
          merchantDisplayName: 'Digital Certificate Repository',
          style: ThemeMode.system,
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Payment successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your support!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Payment failed: $e';
        if (e is StripeException &&
            e.error.localizedMessage == 'The payment flow has been canceled') {
          errorMsg = 'Payment canceled by the user';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
