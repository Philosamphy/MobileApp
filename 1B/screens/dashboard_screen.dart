import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../services/dashboard_service.dart';
import '../services/auth_service.dart';
import '../screens/certificate_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<DashboardService>(
          context,
          listen: false,
        ).loadUserDocuments(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return FutureBuilder<UserRole?>(
      future: Provider.of<AuthService>(
        context,
        listen: false,
      ).getUserRole(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final role = snapshot.data!;
        return Consumer<DashboardService>(
          builder: (context, dashboardService, _) {
            return RefreshIndicator(
              onRefresh: () => dashboardService.loadUserDocuments(user),
              child: _buildDashboardContent(user, dashboardService, role),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardContent(
    dynamic user,
    DashboardService provider,
    UserRole role,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadUserDocuments(user);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    // 过滤逻辑：Recipient只能看到recipientEmail等于自己邮箱且status为issued的证书
    List<DocumentModel> displayDocs = provider.documents;
    if (role == UserRole.recipient) {
      displayDocs = provider.documents
          .where(
            (doc) => doc.recipientEmail == user.email && doc.status == 'issued',
          )
          .toList();
    }
    if (displayDocs.isEmpty) {
      return Center(child: Text('No certificates found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayDocs.length,
      itemBuilder: (context, index) {
        final document = displayDocs[index];
        final now = DateTime.now();
        final isExpired = now.isAfter(document.expiryDate);
        final status = isExpired ? 'expired' : document.status;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(document.title),
            subtitle: Text(
              'Recipient: ${document.recipientName}\nStatus: $status',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChip(status),
                const SizedBox(width: 8),
                if (!isExpired &&
                    (status == 'pending' ||
                        status == 'issued' ||
                        status == 'draft') &&
                    role != UserRole.recipient &&
                    status != 'expired')
                  IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: status == 'pending'
                        ? 'Switch to issued'
                        : 'Switch to pending',
                    onPressed: () async {
                      String newStatus;
                      if (status == 'pending' || status == 'draft') {
                        newStatus = 'issued';
                      } else {
                        newStatus = 'pending';
                      }
                      await FirebaseFirestore.instance
                          .collection('certificates')
                          .doc(document.id)
                          .update({'status': newStatus});
                      final docSnap = await FirebaseFirestore.instance
                          .collection('certificates')
                          .doc(document.id)
                          .get();
                      if (docSnap.exists) {
                        final data = docSnap.data()!;
                        final expiryDate = (data['expiryDate'] as Timestamp)
                            .toDate();
                        final now = DateTime.now();
                        if (now.isAfter(expiryDate) &&
                            data['status'] != 'expired') {
                          await FirebaseFirestore.instance
                              .collection('certificates')
                              .doc(document.id)
                              .update({'status': 'expired'});
                          data['status'] = 'expired';
                        }
                        provider.documents[index] = DocumentModel.fromMap(data);
                        setState(() {});
                      }
                    },
                  ),
                if (!isExpired && status != 'expired')
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () async {
                      final docSnap = await FirebaseFirestore.instance
                          .collection('certificates')
                          .doc(document.id)
                          .get();
                      if (docSnap.exists) {
                        final data = docSnap.data()!;
                        final expiryDate = (data['expiryDate'] as Timestamp)
                            .toDate();
                        final now = DateTime.now();
                        if (now.isAfter(expiryDate) &&
                            data['status'] != 'expired') {
                          await FirebaseFirestore.instance
                              .collection('certificates')
                              .doc(document.id)
                              .update({'status': 'expired'});
                          data['status'] = 'expired';
                        }
                        provider.documents[index] = DocumentModel.fromMap(data);
                        setState(() {});
                      }
                    },
                  ),
                if (isExpired)
                  const Icon(Icons.lock, color: Colors.grey, size: 20),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CertificateDetailScreen(certificate: document),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'issued':
        color = Colors.green;
        label = 'issued';
        break;
      case 'expired':
        color = Colors.grey;
        label = 'expired';
        break;
      default:
        color = Colors.orange;
        label = 'pending';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
