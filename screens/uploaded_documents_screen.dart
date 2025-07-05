import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class UploadedDocumentsScreen extends StatefulWidget {
  const UploadedDocumentsScreen({super.key});

  @override
  State<UploadedDocumentsScreen> createState() =>
      _UploadedDocumentsScreenState();
}

class _UploadedDocumentsScreenState extends State<UploadedDocumentsScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uploaded_documents')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No uploaded documents found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index].data() as Map<String, dynamic>;
              final uploadedAt = doc['uploadedAt'] as Timestamp?;
              final fileSize = doc['fileSize'] as int?;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getFileTypeColor(doc['fileType'] ?? ''),
                    child: Icon(
                      _getFileTypeIcon(doc['fileType'] ?? ''),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    doc['fileName'] ?? 'Unknown File',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '📧 Sent by: ${doc['senderName'] ?? 'Unknown'} (${doc['senderEmail'] ?? 'No email'})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '📅 Uploaded: ${uploadedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(uploadedAt.toDate()) : 'Unknown'}',
                      ),
                      if (fileSize != null) ...[
                        const SizedBox(height: 2),
                        Text('📊 Size: ${_formatFileSize(fileSize)}'),
                      ],
                      const SizedBox(height: 2),
                      _buildStatusChip(doc['status'] ?? 'pending_review'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _viewFile(doc['fileUrl']);
                          break;
                        case 'download':
                          _downloadFile(doc['fileUrl']);
                          break;
                        case 'approve':
                          _updateStatus(documents[index].id, 'approved');
                          break;
                        case 'reject':
                          _updateStatus(documents[index].id, 'rejected');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Download'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Approve'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reject',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Reject'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      case 'pending_review':
        color = Colors.orange;
        text = 'Pending Review';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      case 'doc':
      case 'docx':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _viewFile(String? fileUrl) {
    if (fileUrl != null) {
      launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File URL not available')));
    }
  }

  void _downloadFile(String? fileUrl) {
    if (fileUrl != null) {
      launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File URL not available')));
    }
  }

  Future<void> _updateStatus(String documentId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('uploaded_documents')
          .doc(documentId)
          .update({
            'status': newStatus,
            'reviewedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document $newStatus successfully'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
