import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/client_request_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:certificate/screens/ca_create_certificate_from_request_screen.dart';

class CARequestScreen extends StatefulWidget {
  const CARequestScreen({super.key});

  @override
  State<CARequestScreen> createState() => _CARequestScreenState();
}

class _CARequestScreenState extends State<CARequestScreen> {
  bool _isLoading = false;
  String? _error;
  List<ClientRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('client_request')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => ClientRequestModel.fromMap(doc.data()))
          .toList();

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load requests: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('client_request')
          .doc(requestId)
          .update({
            'status': newStatus,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      // Reload data
      await _loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to: $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  Future<void> _addNotes(String requestId) async {
    final TextEditingController notesController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Enter notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, notesController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('client_request')
            .doc(requestId)
            .update({
              'notes': result,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });

        await _loadRequests();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Notes saved')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save notes: $e')));
        }
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFileRow(String label, String url) {
    return ListTile(
      leading: const Icon(Icons.attach_file),
      title: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRequests,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _requests.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No requests',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: ExpansionTile(
                        title: Text(
                          request.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Applicant: ${request.clientName}'),
                            Text('Email: ${request.email}'),
                            Text(
                              'Request Time: ${dateFormat.format(request.createdAt)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusChip(request.status),
                            const SizedBox(width: 8),
                            if (request.notes != null)
                              const Icon(
                                Icons.note,
                                color: Colors.blue,
                                size: 16,
                              ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (request.certificateUrl != null ||
                                    request.signatureUrl != null) ...[
                                  const Text(
                                    'Uploaded Files:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (request.certificateUrl != null)
                                    _buildFileRow(
                                      'Certificate File',
                                      request.certificateUrl!,
                                    ),
                                  if (request.signatureUrl != null)
                                    _buildFileRow(
                                      'Signature File',
                                      request.signatureUrl!,
                                    ),
                                  const Divider(),
                                ],

                                if (request.notes != null) ...[
                                  const Text(
                                    'Notes:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(request.notes!),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.note_add),
                                        label: const Text('Add Notes'),
                                        onPressed: () => _addNotes(request.id),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (request.status == 'pending') ...[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.check),
                                          label: const Text('Approve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CACreateCertificateFromRequestScreen(
                                                      request: request,
                                                    ),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadRequests(); // Refresh the list
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.close),
                                          label: const Text('Reject'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => _updateRequestStatus(
                                            request.id,
                                            'rejected',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
