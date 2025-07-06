import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';
import 'certificate_detail_screen.dart';
import 'ca_certificate_detail_screen.dart';
import 'readonly_certificate_detail_screen.dart';
import 'certificate_create_screen.dart';

class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Certificate',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificateCreateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('certificates')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No certificates found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final formattedDate = DateFormat(
                'yyyy年MM月dd日 HH:mm:ss',
              ).format(createdAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Recipient: ${data['recipientName'] ?? 'N/A'}'),
                      Text('Organization: ${data['organization'] ?? 'N/A'}'),
                      Text('Status: ${data['status'] ?? 'N/A'}'),
                      Text('Created: $formattedDate'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    final doc = await FirebaseFirestore.instance
                        .collection('certificates')
                        .doc(data['id'])
                        .get();
                    Navigator.pop(context); // Close loading dialog
                    if (doc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CACertificateDetailScreen(
                            certificate: DocumentModel.fromMap(doc.data()!),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
