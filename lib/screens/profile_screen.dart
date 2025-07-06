import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<UserRole?>(
      future: context.read<AuthService>().getUserRole(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final role = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow('Name', user.displayName ?? 'N/A'),
                    _buildInfoRow('Email', user.email ?? 'N/A'),
                    _buildInfoRow('Role', role.toString().split('.').last),
                  ],
                ),
                const SizedBox(height: 16),
                if (role == UserRole.admin)
                  _buildInfoCard(
                    title: 'Admin Actions',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Manage Users'),
                        onTap: () {
                          // TODO: Implement user management
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('System Settings'),
                        onTap: () {
                          // TODO: Implement system settings
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Account Actions',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      onTap: () async {
                        await context.read<AuthService>().signOut();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
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
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
