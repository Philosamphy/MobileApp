import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'services/auth_service.dart';
import 'services/role_service.dart';
import 'services/dashboard_service.dart';
import 'services/certificate_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/role_management_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/certificate_create_screen.dart';
import 'screens/certificate_list_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/certificate_detail_screen.dart';
import 'screens/ca_certificate_detail_screen.dart';
import 'screens/readonly_certificate_detail_screen.dart';
import 'screens/uploaded_documents_screen.dart';
import 'models/document_model.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/metadata_rules_screen.dart';
import 'screens/recipient_upload_screen.dart';
import 'screens/viewer_dashboard_screen.dart';
import 'screens/client_profile_screen.dart';
import 'screens/client_apply_screen.dart';
import 'screens/client_management_screen.dart';
import 'screens/ca_request_screen.dart';
import 'screens/recipient_documents_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe only on supported platforms
  if (!kIsWeb) {
    try {
      Stripe.publishableKey =
          'pk_test_51Rb17F4J2VGospN8ptRdtxQInRjeplxEtZBKG0pAW5MWYqAOIBFwz4gS7hri8lp10zyF4IqWHjHZvnMJdgqIzMcI00PAqrDCQk';
    } catch (e) {
      print('Stripe initialization failed: $e');
      // Continue without Stripe
    }
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase if possible
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => RoleService()),
        ChangeNotifierProvider(create: (_) => DashboardService()),
        Provider(create: (_) => CertificateService()),
      ],
      child: MaterialApp(
        title: 'Digital Certificate Repository',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authService.isLoggedIn) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        if (user == null) {
          return const LoginScreen();
        }
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
                        title: const Text('Enter Certificate Token'),
                        content: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Please enter Token',
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
                    // Auto-extract Token (supports full links and pure tokens)
                    final reg = RegExp(r'([a-fA-F0-9\-]{32,})$');
                    final match = reg.firstMatch(token);
                    final pureToken = match != null
                        ? match.group(1) ?? token
                        : token;
                    final query = await FirebaseFirestore.instance
                        .collection('certificates')
                        .where('shareToken', isEqualTo: pureToken)
                        .limit(1)
                        .get();
                    if (query.docs.isNotEmpty) {
                      final data = query.docs.first.data();
                      final certificate = DocumentModel.fromMap(data);

                      // Navigate to different detail screens based on user role
                      if (user.role == 'ca' ||
                          user.role == 'certificateAuthority' ||
                          user.isCA ||
                          user.isAdmin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CACertificateDetailScreen(
                              certificate: certificate,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReadOnlyCertificateDetailScreen(
                                  certificate: certificate,
                                ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Certificate not found')),
                      );
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 56),
                  child: CircleAvatar(
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.displayName?[0] ?? user.email[0].toUpperCase(),
                          )
                        : null,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      authService.signOut();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final items = <PopupMenuEntry<String>>[];
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    );
                    return items;
                  },
                ),
              ),
            ],
          ),
          body: _getPage(_selectedIndex, user),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              if (user.isAdmin) ...[
                const NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'User Management',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Activity',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.rule),
                  label: 'Metadata',
                ),
              ] else if (user.role == 'ca' ||
                  user.role == 'certificateAuthority' ||
                  user.isCA) ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.upload),
                  label: 'Upload',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_open),
                  label: 'Documents',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'Client',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.request_page),
                  label: 'Request',
                ),
              ] else if (user.role == 'recipient') ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.upload),
                  label: 'Upload',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_open),
                  label: 'Documents',
                ),
              ] else if (user.role == 'client') ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.assignment),
                  label: 'Apply',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ] else if (user.role == 'viewer') ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Support Us',
                ),
              ] else ...[
                // Default destinations for unknown roles to prevent crash
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _getPage(int index, dynamic user) {
    if (user.isAdmin) {
      if (index == 0) {
        return const RoleManagementScreen();
      }
      if (index == 1) {
        return const ActivityScreen();
      }
      if (index == 2) {
        return const MetadataRulesScreen();
      }
    } else if (user.role == 'ca' ||
        user.role == 'certificateAuthority' ||
        user.isCA) {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const CertificateCreateScreen();
      }
      if (index == 2) {
        return const UploadedDocumentsScreen();
      }
      if (index == 3) {
        return const ClientManagementScreen();
      }
      if (index == 4) {
        return const CARequestScreen();
      }
    } else if (user.role == 'recipient') {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const RecipientUploadScreen();
      }
      if (index == 2) {
        return const RecipientDocumentsScreen();
      }
    } else if (user.role == 'client') {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const ClientApplyScreen();
      }
      if (index == 2) {
        return const ClientProfileScreen();
      }
    } else if (user.role == 'viewer') {
      if (index == 0) {
        return const ViewerDashboardScreen();
      }
      if (index == 1) {
        return const Center(child: Text('Support Us Page'));
      }
    } else {
      // Default page for unknown roles
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        // Default placeholder for any other logged-in user
        return const Center(child: Text('Page not available'));
      }
    }
    return const Center(child: Text('Page Placeholder'));
  }
}
