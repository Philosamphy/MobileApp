import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class CertificateEditScreen extends StatefulWidget {
  final DocumentModel certificate;
  const CertificateEditScreen({super.key, required this.certificate});

  @override
  State<CertificateEditScreen> createState() => _CertificateEditScreenState();
}

class _CertificateEditScreenState extends State<CertificateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _recipientNameController;
  late TextEditingController _recipientEmailController;
  late TextEditingController _organizationController;
  late TextEditingController _purposeController;
  late DateTime _issuedDate;
  late DateTime _expiryDate;
  late String _status;
  bool _isLoading = false;
  Map<String, bool> _requiredMap = {};

  final List<String> _statusOptions = [
    'draft',
    'pending',
    'approved',
    'issued',
    'expired',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.certificate;
    _titleController = TextEditingController(text: c.title);
    _recipientNameController = TextEditingController(text: c.recipientName);
    _recipientEmailController = TextEditingController(text: c.recipientEmail);
    _organizationController = TextEditingController(text: c.organization);
    _purposeController = TextEditingController(text: c.purpose);
    _issuedDate = c.issuedDate;
    _expiryDate = c.expiryDate;
    _status = c.status;
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
    _recipientEmailController.dispose();
    _organizationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Validate metadata_rules
    final fieldMap = {
      'title': _titleController.text,
      'recipientName': _recipientNameController.text,
      'recipientEmail': _recipientEmailController.text,
      'organization': _organizationController.text,
      'purpose': _purposeController.text,
      'issuedDate': _issuedDate,
      'expiryDate': _expiryDate,
    };
    for (final entry in _requiredMap.entries) {
      if (entry.value) {
        final v = fieldMap[entry.key];
        if (v == null || (v is String && v.trim().isEmpty)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${entry.key} is required')));
          return;
        }
      }
    }
    setState(() => _isLoading = true);
    try {
      final updated = widget.certificate.copyWith(
        title: _titleController.text,
        recipientName: _recipientNameController.text,
        recipientEmail: _recipientEmailController.text,
        organization: _organizationController.text,
        purpose: _purposeController.text,
        issuedDate: _issuedDate,
        expiryDate: _expiryDate,
        status: _status,
        updatedAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc(updated.id)
          .update(updated.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate updated successfully')),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _status == 'expired';
    final role = context.watch<UserRole?>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Certificate')),
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
                      readOnly: isExpired,
                      enabled: !isExpired,
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
                      readOnly: isExpired,
                      enabled: !isExpired,
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
                      controller: _recipientEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: isExpired,
                      enabled: !isExpired,
                      validator: (value) {
                        if ((_requiredMap['recipientEmail'] ?? true) &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter recipient email';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Organization',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: isExpired,
                      enabled: !isExpired,
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
                      readOnly: isExpired,
                      enabled: !isExpired,
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
                            onTap: isExpired
                                ? null
                                : () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _issuedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null)
                                      setState(() => _issuedDate = date);
                                  },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Expiry Date'),
                            subtitle: Text(
                              _expiryDate.toString().split(' ')[0],
                            ),
                            onTap: isExpired
                                ? null
                                : () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _expiryDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null)
                                      setState(() => _expiryDate = date);
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!(isExpired && role == UserRole.certificateAuthority))
                      DropdownButtonFormField<String>(
                        value: _status == 'issued' ? 'issued' : 'pending',
                        items: [
                          const DropdownMenuItem(
                            value: 'pending',
                            child: Text('pending'),
                          ),
                          const DropdownMenuItem(
                            value: 'issued',
                            child: Text('issued'),
                          ),
                        ],
                        onChanged: isExpired
                            ? null
                            : (v) => setState(() => _status = v ?? _status),
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        disabledHint: const Text('expired'),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isExpired ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
