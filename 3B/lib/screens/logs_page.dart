import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class LogsPage extends StatelessWidget {
  const LogsPage({Key? key}) : super(key: key);

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Logs'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading logs'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No logs available'));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              final action = log['action'];
              final filename = log['filename'] ?? '';
              final comment = log['comment'] ?? '';
              final timestamp = log['timestamp'] as Timestamp;

              return ListTile(
                leading: Icon(
                  action == 'approved' ? Icons.check : Icons.close,
                  color: action == 'approved' ? Colors.green : Colors.red,
                ),
                title: Text('$action → $filename'),
                subtitle: Text(
                  '${formatTimestamp(timestamp)}'
                      '${comment.isNotEmpty ? '\nComment: $comment' : ''}',
                ),
                isThreeLine: comment.isNotEmpty,
              );
            },
          );
        },
      ),
    );
  }
}
