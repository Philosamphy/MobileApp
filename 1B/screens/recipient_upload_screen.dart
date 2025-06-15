import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/document_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RecipientUploadScreen extends StatefulWidget {
  const RecipientUploadScreen({super.key});

  @override
  State<RecipientUploadScreen> createState() => _RecipientUploadScreenState();
}

class _RecipientUploadScreenState extends State<RecipientUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime _issuedDate = DateTime.now();
  DateTime? _expiryDate;
  File? _certificateFile;
  File? _signatureFile;
  bool _isPhysicalDocument = false;
  bool _isLoading = false;
  Map<String, bool> _requiredMap = {};

  @override
  void initState() {
    super.initState();
    _loadRequiredMap();
  }

  Future<void> _loadRequiredMap() async {
    final rulesDoc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('metadata_rules')
        .get();
    setState(() {
      _requiredMap = rulesDoc.exists && rulesDoc.data() != null
          ? Map<String, bool>.from(rulesDoc.data()!['required'] ?? {})
          : {};
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recipientNameController.dispose();
    _organizationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submitCertificate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) throw Exception('User not logged in');
      final uuid = Uuid();
      final shareToken = uuid.v4();
      final certificate = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        recipientName: _recipientNameController.text,
        recipientEmail: user.email,
        recipientId: user.uid,
        issuerName: '',
        issuerId: '',
        organization: _organizationController.text,
        purpose: _purposeController.text,
        status: 'pending',
        isPhysicalDocument: false,
        createdAt: DateTime.now(),
        issuedDate: _issuedDate,
        expiryDate:
            _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
        shareToken: shareToken,
      );
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc(certificate.id)
          .set(certificate.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate uploaded successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading certificate: $e')),
        );
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
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Certificate')),
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
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((_requiredMap['title'] ?? true) &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((_requiredMap['recipientName'] ?? true) &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user?.email ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Recipient Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Organization',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((_requiredMap['organization'] ?? true) &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter organization';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((_requiredMap['purpose'] ?? true) &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter purpose';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Issued Date'),
                            subtitle: Text(
                              _issuedDate.toString().split(' ')[0],
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _issuedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _issuedDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Expiry Date'),
                            subtitle: Text(
                              _expiryDate != null
                                  ? _expiryDate.toString().split(' ')[0]
                                  : '请选择',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _expiryDate = date;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Physical Document'),
                      value: _isPhysicalDocument,
                      onChanged: (value) {
                        setState(() {
                          _isPhysicalDocument = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitCertificate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Upload Certificate'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
