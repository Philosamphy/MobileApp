import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int approvedCount = 0;
  int rejectedCount = 0;
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final firestore = FirebaseFirestore.instance;

    final approvedSnap = await firestore
        .collection('certificates')
        .where('status', isEqualTo: 'approved')
        .get();

    final rejectedSnap = await firestore
        .collection('certificates')
        .where('status', isEqualTo: 'rejected')
        .get();

    final pendingSnap = await firestore
        .collection('certificates')
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      approvedCount = approvedSnap.size;
      rejectedCount = rejectedSnap.size;
      pendingCount = pendingSnap.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard('✅ Approved', approvedCount, Colors.green),
            _buildStatCard('❌ Rejected', rejectedCount, Colors.red),
            _buildStatCard('🕓 Pending', pendingCount, Colors.orange),
            const SizedBox(height: 20),
            _buildStatCard('📂 Total Files', approvedCount + rejectedCount + pendingCount, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.folder, color: color),
        title: Text(title),
        trailing: Text(count.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}


