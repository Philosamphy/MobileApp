import 'package:flutter/material.dart';
import 'client_service.dart';
import 'client_model.dart';
import 'certificate_request_form.dart';
import 'certificate_approval_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  final ClientService _clientService = ClientService();
  List<CertificateRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    final requests = await _clientService.fetchMyRequests();
    setState(() {
      _requests = requests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Request Certificate'),
            trailing: const Icon(Icons.add),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CertificateRequestForm()),
            ),
          ),
          ListTile(
            title: const Text('Pending Approvals'),
            trailing: const Icon(Icons.verified_user),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CertificateApprovalScreen()),
            ),
          ),
          ..._requests.map((req) => ListTile(
            title: Text(req.recipientName),
            subtitle: Text(req.status),
          )),
        ],
      ),
    );
  }
}
