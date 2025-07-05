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
import 'package:url_launcher/url_launcher.dart';
import '../models/document_model.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/certificate_service.dart';
import '../services/dashboard_service.dart';
import '../services/file_upload_service.dart';
import 'package:file_selector/file_selector.dart';
import 'certificate_edit_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class CertificateDetailScreen extends StatelessWidget {
  final DocumentModel certificate;

  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(certificate.title),
        actions: [
          if (certificate.status != 'expired')
            FutureBuilder<UserRole?>(
              future: user != null
                  ? Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).getUserRole(user.uid)
                  : Future.value(null),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final role = snapshot.data!;
                final canEdit =
                    role == UserRole.certificateAuthority ||
                    role == UserRole.admin;
                if (role == UserRole.recipient) {
                  return const SizedBox.shrink();
                }
                if (canEdit || certificate.status != 'expired') {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CertificateEditScreen(certificate: certificate),
                        ),
                      );
                      if (updated != null) {
                        // Refresh detail page (rebuild page)
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CertificateDetailScreen(certificate: updated),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          if (certificate.status != 'expired')
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                String? token = certificate.shareToken;
                if (token == null || token.isEmpty) {
                  final uuid = Uuid();
                  token = uuid.v4();
                  await FirebaseFirestore.instance
                      .collection('certificates')
                      .doc(certificate.id)
                      .update({'shareToken': token});
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
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                // TODO: Implement file download/view
              },
              child: const Text('Download'),
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> _generateAndSavePDF(
    BuildContext context,
    DocumentModel cert, {
    bool silent = false,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) => pw.Stack(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Certificate',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Title: ${cert.title}'),
                pw.Text('Recipient: ${cert.recipientName}'),
                pw.Text('Email: ${cert.recipientEmail}'),
                pw.Text('Organization: ${cert.organization}'),
                pw.Text('Purpose: ${cert.purpose}'),
                pw.Text('Issued: ${cert.issuedDate.toLocal()}'),
                pw.Text('Expiry: ${cert.expiryDate.toLocal()}'),
                pw.Text('Status: ${cert.status}'),
                pw.Text('Token: ${cert.shareToken ?? ''}'),
              ],
            ),
            if (cert.status == 'issued')
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.18,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue, width: 6),
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
        ),
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/certificate_${cert.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    if (!silent && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to: ${file.path}')));
      await _openPDF(file.path);
    }
    return file;
  }

  Future<void> _openPDF(String path) async {
    try {
      await launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
    } catch (e) {
      // You can prompt the user if needed
    }
  }
}
