import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipient_profile_model.dart';

class RecipientManagementScreen extends StatefulWidget {
  const RecipientManagementScreen({super.key});

  @override
  State<RecipientManagementScreen> createState() =>
      _RecipientManagementScreenState();
}

class _RecipientManagementScreenState extends State<RecipientManagementScreen> {
  List<RecipientProfileModel> recipients = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadRecipients();
  }

  Future<void> loadRecipients() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recipient_profiles')
          .get();

      setState(() {
        recipients = querySnapshot.docs
            .map((doc) => RecipientProfileModel.fromMap(doc.data(), doc.id))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading recipients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<RecipientProfileModel> get filteredRecipients {
    if (searchQuery.isEmpty) {
      return recipients;
    }
    return recipients.where((recipient) {
      return recipient.displayName?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true ||
          recipient.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          recipient.phoneNumber?.contains(searchQuery) == true ||
          recipient.organization?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              loadRecipients();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search recipients...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Recipients list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipients.isEmpty
                ? const Center(child: Text('No recipients found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipients.length,
                    itemBuilder: (context, index) {
                      final recipient = filteredRecipients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: recipient.profileImageUrl != null
                                ? NetworkImage(recipient.profileImageUrl!)
                                : null,
                            child: recipient.profileImageUrl == null
                                ? Text(
                                    recipient.displayName?[0] ??
                                        recipient.email[0].toUpperCase(),
                                  )
                                : null,
                          ),
                          title: Text(recipient.displayName ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipient.email),
                              if (recipient.phoneNumber != null)
                                Text('Phone: ${recipient.phoneNumber}'),
                              if (recipient.organization != null)
                                Text('Organization: ${recipient.organization}'),
                              Text(
                                'Status: ${recipient.isActive ? 'Active' : 'Inactive'}',
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editRecipient(recipient),
                              ),
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () => _viewRecipient(recipient),
                              ),
                            ],
                          ),
                          onTap: () => _viewRecipient(recipient),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _viewRecipient(RecipientProfileModel recipient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipientDetailScreen(recipient: recipient),
      ),
    );
  }

  void _editRecipient(RecipientProfileModel recipient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipientEditScreen(recipient: recipient),
      ),
    ).then((_) {
      // Refresh the list after editing
      loadRecipients();
    });
  }
}

class RecipientDetailScreen extends StatelessWidget {
  final RecipientProfileModel recipient;

  const RecipientDetailScreen({super.key, required this.recipient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecipientEditScreen(recipient: recipient),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: recipient.profileImageUrl != null
                    ? NetworkImage(recipient.profileImageUrl!)
                    : null,
                child: recipient.profileImageUrl == null
                    ? Text(
                        recipient.displayName?[0] ??
                            recipient.email[0].toUpperCase(),
                        style: const TextStyle(fontSize: 30),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard('Personal Information', [
              _buildDetailRow('Name', recipient.displayName ?? 'Not provided'),
              _buildDetailRow('Email', recipient.email),
              _buildDetailRow('Phone', recipient.phoneNumber ?? 'Not provided'),
              _buildDetailRow(
                'Status',
                recipient.isActive ? 'Active' : 'Inactive',
              ),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard('Account Information', [
              _buildDetailRow('User ID', recipient.id),
              _buildDetailRow('Role', 'Recipient'),
              _buildDetailRow(
                'Created',
                recipient.createdAt?.toString() ?? 'Unknown',
              ),
              _buildDetailRow(
                'Last Updated',
                recipient.updatedAt?.toString() ?? 'Unknown',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class RecipientEditScreen extends StatefulWidget {
  final RecipientProfileModel recipient;

  const RecipientEditScreen({super.key, required this.recipient});

  @override
  State<RecipientEditScreen> createState() => _RecipientEditScreenState();
}

class _RecipientEditScreenState extends State<RecipientEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipient.displayName);
    _phoneController = TextEditingController(
      text: widget.recipient.phoneNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('recipient_profiles')
          .doc(widget.recipient.id)
          .update({
            'displayName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipient updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update recipient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipient'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveChanges, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Email'),
                subtitle: Text(widget.recipient.email),
                trailing: const Icon(Icons.lock, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('User ID'),
                subtitle: Text(widget.recipient.id),
                trailing: const Icon(Icons.lock, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
