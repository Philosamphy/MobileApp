import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Logs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activity logs found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat(
                'yyyy年MM月dd日 HH:mm:ss',
              ).format(timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _showActivityDetails(context, data),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getActionIcon(data['action'] as String),
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getActionTitle(data['action'] as String),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('User ID: ${data['userId']}'),
                        if (data['newRole'] != null)
                          Text('New Role: ${data['newRole']}'),
                        Text('Time: $formattedDate'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showActivityDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    String userEmail = 'Unknown';

    try {
      // Get user email from userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .get();

      if (userDoc.exists) {
        userEmail = userDoc.data()?['email'] ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching user email: $e');
    }

    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(timestamp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getActionIcon(data['action'] as String), color: Colors.blue),
            const SizedBox(width: 8),
            Text(_getActionTitle(data['action'] as String)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('User ID', data['userId']),
            _buildDetailRow('User Email', userEmail),
            if (data['newRole'] != null)
              _buildDetailRow('New Role', data['newRole']),
            _buildDetailRow('Action', data['action']),
            _buildDetailRow('Timestamp', formattedDate),
            if (data['logId'] != null) _buildDetailRow('Log ID', data['logId']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'role_created':
        return Icons.person_add;
      case 'role_update':
        return Icons.people;
      default:
        return Icons.info;
    }
  }

  String _getActionTitle(String action) {
    switch (action) {
      case 'role_created':
        return 'Role Created';
      case 'role_update':
        return 'Role Update';
      default:
        return action;
    }
  }
}
