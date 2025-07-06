import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/recipient_profile_model.dart';

class RecipientProfileScreen extends StatefulWidget {
  const RecipientProfileScreen({super.key});

  @override
  State<RecipientProfileScreen> createState() => _RecipientProfileScreenState();
}

class _RecipientProfileScreenState extends State<RecipientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  bool _isEditing = false;
  bool _isLoading = false;
  RecipientProfileModel? _profileData;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('recipient_profiles')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          _profileData = RecipientProfileModel.fromMap(doc.data()!, doc.id);
        } else {
          // Create a default profile model if one doesn't exist
          _profileData = RecipientProfileModel(
            id: user.uid,
            email: user.email ?? '', // Ensure email is not null
            displayName: user.displayName,
          );
        }
        _populateControllers();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateControllers() {
    if (_profileData != null) {
      _displayNameController.text = _profileData!.displayName ?? '';
      _phoneNumberController.text = _profileData!.phoneNumber ?? '';
      _addressController.text = _profileData!.address ?? '';
      _descriptionController.text = _profileData!.description ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        final updateData = {
          'email': user.email, // Use current user's email directly
          'displayName': _displayNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'description': _descriptionController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add createdAt timestamp if it's a new profile
        if (_profileData!.createdAt == null) {
          updateData['createdAt'] = FieldValue.serverTimestamp();
        }

        await FirebaseFirestore.instance
            .collection('recipient_profiles')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadProfileData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else ...[
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _populateControllers(); // Reset changes
              },
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              _buildProfileHeader(user),
              const SizedBox(height: 24),

              // Form fields
              _buildTextField(
                controller: _displayNameController,
                label: 'Name',
                enabled: _isEditing,
              ),
              _buildTextField(
                controller: _phoneNumberController,
                label: 'Phone Number',
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                enabled: _isEditing,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                enabled: _isEditing,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.displayName?[0] ??
                          user?.email[0].toUpperCase() ??
                          'U',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _displayNameController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _profileData?.email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter your $label',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
