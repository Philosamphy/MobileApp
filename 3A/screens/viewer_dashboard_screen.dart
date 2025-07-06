import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'support_us_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'certificate_detail_screen.dart';
import '../models/document_model.dart';

class ViewerDashboardScreen extends StatefulWidget {
  const ViewerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ViewerDashboardScreen> createState() => _ViewerDashboardScreenState();
}

class _ViewerDashboardScreenState extends State<ViewerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Certificate Repository'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Certificate by Token',
            onPressed: () async {
              final token = await showDialog<String>(
                context: context,
                builder: (context) {
                  String input = '';
                  return AlertDialog(
                    title: const Text('Enter Certificate Token or Full Link'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Please enter Token or full link',
                      ),
                      onChanged: (v) => input = v,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, input),
                        child: const Text('Search'),
                      ),
                    ],
                  );
                },
              );
              if (token != null && token.isNotEmpty) {
                // Optimize token extraction logic, support full links and pure tokens
                String pureToken = token.trim();
                // Try to extract token from link (UUID or longer alphanumeric string)
                final reg = RegExp(r'([a-zA-Z0-9\-]{16,})');
                final match = reg.allMatches(token).toList();
                if (match.isNotEmpty) {
                  // Take the last match (usually the token)
                  pureToken = match.last.group(1) ?? token.trim();
                }
                final query = await FirebaseFirestore.instance
                    .collection('certificates')
                    .where('shareToken', isEqualTo: pureToken)
                    .limit(1)
                    .get();
                if (query.docs.isNotEmpty) {
                  final data = query.docs.first.data();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CertificateDetailScreen(
                        certificate: DocumentModel.fromMap(data),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Certificate not found')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Enter your link',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enter the certificate link to view',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportUsScreen()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Support Us',
          ),
        ],
      ),
    );
  }
}
