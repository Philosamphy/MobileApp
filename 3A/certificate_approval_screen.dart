import 'package:flutter/material.dart';
import 'client_service.dart';
import 'client_model.dart';

class CertificateApprovalScreen extends StatefulWidget {
  const CertificateApprovalScreen({super.key});

  @override
  State<CertificateApprovalScreen> createState() => _CertificateApprovalScreenState();
}

class _CertificateApprovalScreenState extends State<CertificateApprovalScreen> {
  final ClientService _clientService = ClientService();
  List<CertificateRequest> _pending = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  void _loadPending() async {
    final data = await _clientService.fetchPendingApprovals();
    setState(() {
      _pending = data;
    });
  }

  void _approve(String id) async {
    await _clientService.approveRequest(id, true);
    _loadPending();
  }

  void _reject(String id) async {
    await _clientService.approveRequest(id, false);
    _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: ListView(
        children: _pending.map((req) => Card(
          child: ListTile(
            title: Text(req.recipientName),
            subtitle: Text(req.purpose),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approve(req.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _reject(req.id),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
