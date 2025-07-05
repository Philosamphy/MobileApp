import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MetadataRulesScreen extends StatefulWidget {
  const MetadataRulesScreen({super.key});

  @override
  State<MetadataRulesScreen> createState() => _MetadataRulesScreenState();
}

class _MetadataRulesScreenState extends State<MetadataRulesScreen> {
  // Certificate field list
  final List<String> fields = [
    'title',
    'recipientName',
    'recipientEmail',
    'organization',
    'purpose',
    'issuedDate',
    'expiryDate',
  ];
  // Field rules (true=required, false=optional)
  Map<String, bool> requiredMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('metadata_rules')
        .get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        requiredMap = Map<String, bool>.from(doc.data()!['required'] ?? {});
        isLoading = false;
      });
    } else {
      setState(() {
        requiredMap = {for (var f in fields) f: true};
        isLoading = false;
      });
    }
  }

  Future<void> _saveRules() async {
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('metadata_rules')
        .set({'required': requiredMap, 'updatedAt': DateTime.now()});
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rules saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Metadata Rules')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Configure which certificate fields are required and which are optional:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...fields.map(
                  (f) => SwitchListTile(
                    title: Text(f),
                    value: requiredMap[f] ?? true,
                    onChanged: (v) {
                      setState(() {
                        requiredMap[f] = v;
                      });
                    },
                    secondary: const Icon(Icons.rule),
                    subtitle: Text(
                      (requiredMap[f] ?? true) ? 'Required' : 'Optional',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveRules,
                  child: const Text('Save Rules'),
                ),
              ],
            ),
    );
  }
}
