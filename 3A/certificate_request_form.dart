import 'package:flutter/material.dart';
import 'client_service.dart';
import 'client_model.dart';

class CertificateRequestForm extends StatefulWidget {
  const CertificateRequestForm({super.key});

  @override
  State<CertificateRequestForm> createState() => _CertificateRequestFormState();
}

class _CertificateRequestFormState extends State<CertificateRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _purposeController = TextEditingController();

  final ClientService _clientService = ClientService();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = CertificateRequest(
        id: UniqueKey().toString(),
        recipientName: _recipientNameController.text,
        recipientEmail: _recipientEmailController.text,
        organization: _organizationController.text,
        purpose: _purposeController.text,
        dateRequested: DateTime.now(),
      );
      _clientService.submitCertificateRequest(request);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Certificate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Recipient Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _recipientEmailController,
                decoration: const InputDecoration(labelText: 'Recipient Email'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _organizationController,
                decoration: const InputDecoration(labelText: 'Organization'),
              ),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(labelText: 'Purpose'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
