import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/file_model.dart';
import '../widgets/approval_card.dart';
import 'admin_dashboard_page.dart';
import 'logs_page.dart';

class ApprovalPage extends StatelessWidget {
  Stream<List<FileModel>> getPendingFilesStream() {
    return FirebaseFirestore.instance
        .collection('certificates')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FileModel.fromSnapshot(doc)).toList());
  }

  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('certificates')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> logAction(String fileId, String filename, String action,
      {String? comment}) async {
    await FirebaseFirestore.instance.collection('logs').add({
      'fileId': fileId,
      'filename': filename,
      'action': action,
      'timestamp': Timestamp.now(),
      'comment': comment ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('True Copy Approval'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Admin Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Logs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<FileModel>>(
        stream: getPendingFilesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading files'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending files'));
          }

          final fileList = snapshot.data!;
          return ListView.builder(
            itemCount: fileList.length,
            itemBuilder: (context, index) {
              final file = fileList[index];

              return ApprovalCard(
                filename: file.filename,
                uploader: file.uploader,
                uploadDate: file.uploadDate,
                onApprove: () async {
                  await updateStatus(file.id, 'approved');
                  await logAction(file.id, file.filename, 'approved');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${file.filename} approved')),
                  );
                },
                onRejectWithComment: (String comment) async {
                  await FirebaseFirestore.instance
                      .collection('certificates')
                      .doc(file.id)
                      .update({
                    'status': 'rejected',
                    'comment': comment,
                  });
                  await logAction(file.id, file.filename, 'rejected',
                      comment: comment);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${file.filename} rejected')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


