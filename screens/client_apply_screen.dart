import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/client_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'client_applied_list_screen.dart';

class ClientApplyScreen extends StatefulWidget {
  const ClientApplyScreen({super.key});

  @override
  State<ClientApplyScreen> createState() => _ClientApplyScreenState();
}

class _ClientApplyScreenState extends State<ClientApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) throw Exception('User not logged in');

      final request = ClientRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        email: _emailController.text,
        clientId: user.uid,
        clientName: user.displayName ?? 'Unknown',
        certificateUrl: null,
        signatureUrl: null,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('client_request')
          .doc(request.id)
          .set(request.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );
        // Clear form
        _titleController.clear();
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Certificate')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Certificate Title',
                        border: OutlineInputBorder(),
                        hintText: 'Enter certificate title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter certificate title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        hintText: 'Enter your email address',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Request'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ClientAppliedListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('View My Applied Requests'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
