import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'certificate_list_screen.dart';
import 'certificate_create_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipient_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<UserRole?>(
      future: context.read<AuthService>().getUserRole(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;
        final isCA = role == UserRole.certificateAuthority;
        final isAdmin = role == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Digital Certificate Repository'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthService>().signOut();
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              const CertificateListScreen(),
              const RecipientUploadScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.list),
                label: 'Certificates',
              ),
              const NavigationDestination(
                icon: Icon(Icons.upload),
                label: 'Upload',
              ),
            ],
          ),
        );
      },
    );
  }
}
