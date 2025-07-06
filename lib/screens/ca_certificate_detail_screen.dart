import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/document_model.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'certificate_edit_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/certificate_service.dart';
import '../services/dashboard_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';

class CACertificateDetailScreen extends StatelessWidget {
  final DocumentModel certificate;

  const CACertificateDetailScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    // Debug: Print to confirm this page is loaded
    print(
      'CACertificateDetailScreen loaded for certificate: ${certificate.title}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(certificate.title),
        actions: [
          // Delete button (CA only)
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Certificate',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Are you sure you want to permanently delete this certificate?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await FirebaseFirestore.instance
                      .collection('certificates')
                      .doc(certificate.id)
                      .delete();

                  // Add log entry for certificate deletion
                  await FirebaseFirestore.instance.collection('logs').add({
                    'action': 'certificate_deleted',
                    'userId': user?.uid ?? 'unknown',
                    'certificateId': certificate.id,
                    'certificateTitle': certificate.title,
                    'recipientEmail': certificate.recipientEmail,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Certificate deleted successfully'),
                      ),
                    );
                    Navigator.pop(context); // Go back
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting certificate: $e')),
                    );
                  }
                }
              }
            },
          ),

          // Edit button (CA only)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Certificate',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CertificateEditScreen(certificate: certificate),
                ),
              );
              if (updated != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CACertificateDetailScreen(certificate: updated),
                  ),
                );
              }
            },
          ),

          // Share button
          if (certificate.status != 'expired')
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Copy Share Link',
              onPressed: () async {
                String? token = certificate.shareToken;
                if (token == null || token.isEmpty) {
                  final uuid = Uuid();
                  token = uuid.v4();
                  await FirebaseFirestore.instance
                      .collection('certificates')
                      .doc(certificate.id)
                      .update({
                        'shareToken': token,
                        'shareTokenCreatedAt': FieldValue.serverTimestamp(),
                      });
                }
                final link = 'https://your-app.com/certificate/$token';
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share link copied: $link')),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Certificate Information',
              children: [
                _buildInfoRow('Title', certificate.title),
                _buildInfoRow('Status', certificate.status),
                _buildInfoRow('Organization', certificate.organization),
                _buildInfoRow('Purpose', certificate.purpose),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Recipient Information',
              children: [
                _buildInfoRow('Name', certificate.recipientName),
                _buildInfoRow('Email', certificate.recipientEmail),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Issuer Information',
              children: [
                _buildInfoRow('Name', certificate.issuerName),
                _buildInfoRow('ID', certificate.issuerId),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Dates',
              children: [
                _buildInfoRow(
                  'Created',
                  dateFormat.format(certificate.createdAt),
                ),
                _buildInfoRow(
                  'Issued',
                  dateFormat.format(certificate.issuedDate),
                ),
                _buildInfoRow(
                  'Expiry',
                  dateFormat.format(certificate.expiryDate),
                ),
                if (certificate.updatedAt != null)
                  _buildInfoRow(
                    'Last Updated',
                    dateFormat.format(certificate.updatedAt!),
                  ),
              ],
            ),
            if (certificate.certificateUrl != null ||
                certificate.signatureUrl != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Files',
                children: [
                  if (certificate.certificateUrl != null)
                    _buildFileRow('Certificate', certificate.certificateUrl!),
                  if (certificate.signatureUrl != null)
                    _buildFileRow('Signature', certificate.signatureUrl!),
                ],
              ),
            ],
            if (certificate.status != 'expired') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download'),
                onPressed: () async {
                  await _generateAndSavePDF(context, certificate);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share PDF'),
                onPressed: () async {
                  final file = await _generateAndSavePDF(
                    context,
                    certificate,
                    silent: true,
                  );
                  if (file != null) {
                    await Share.shareXFiles([
                      XFile(file.path),
                    ], text: 'Here is your certificate PDF');
                  }
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar:
          (certificate.shareToken != null && certificate.status != 'expired')
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Token: ${certificate.shareToken}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy Token',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: certificate.shareToken!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copied')),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => _launchUrl(url),
            child: const Text('View File'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<File?> _generateAndSavePDF(
    BuildContext context,
    DocumentModel certificate, {
    bool silent = false,
  }) async {
    if (!silent && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // 新增：查找issuer邮箱
      String? issuerEmail;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(certificate.issuerId)
            .get();
        if (userDoc.exists) {
          issuerEmail = userDoc.data()?['email'] as String?;
        }
      } catch (e) {
        issuerEmail = null;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Header(
                      level: 0,
                      child: pw.Text(
                        certificate.title,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Recipient: ${certificate.recipientName}'),
                    pw.Text('Email: ${certificate.recipientEmail}'),
                    pw.Text('Organization: ${certificate.organization}'),
                    pw.Text('Purpose: ${certificate.purpose}'),
                    pw.Text('Status: ${certificate.status}'),
                    pw.Text(
                      'Issued Date: ${DateFormat('yyyy-MM-dd').format(certificate.issuedDate)}',
                    ),
                    pw.Text(
                      'Expiry Date: ${DateFormat('yyyy-MM-dd').format(certificate.expiryDate)}',
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Issued by: ${issuerEmail ?? certificate.issuerId}',
                    ),
                    if (certificate.shareToken != null)
                      pw.Text('Token: ${certificate.shareToken}'),
                  ],
                ),
                // Add watermark for issued certificates
                if (certificate.status == 'issued')
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.18,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.blue,
                            width: 6,
                          ),
                          borderRadius: pw.BorderRadius.circular(12),
                          color: PdfColors.white,
                        ),
                        child: pw.Text(
                          'ISSUED',
                          style: pw.TextStyle(
                            fontSize: 72,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${certificate.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!silent && context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved to: ${file.path}')));
      }

      return file;
    } catch (e) {
      if (!silent && context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
      return null;
    }
  }
}
