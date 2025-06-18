import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
import 'models/document_model.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/metadata_rules_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recipient_upload_screen.dart';
import 'screens/viewer_dashboard_screen.dart';
import 'screens/support_us_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Stripe
  Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // 如果已经初始化，忽略异常，保证不影响后续功能
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
                tooltip: '通过Token查证书',
                onPressed: () async {
                  final token = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String input = '';
                      return AlertDialog(
                        title: const Text('输入证书Token'),
                        content: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: '请输入Token',
                          ),
                          onChanged: (v) => input = v,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, input),
                            child: const Text('查找'),
                          ),
                        ],
                      );
                    },
                  );
                  if (token != null && token.isNotEmpty) {
                    // 自动提取Token（支持完整链接和纯Token）
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CertificateDetailScreen(
                            certificate: DocumentModel.fromMap(data),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('未找到对应证书')));
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
                    } else if (value == 'profile') {
                      // TODO: Show profile page
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.displayName ?? 'Unnamed User'),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
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
                  ],
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
              ] else if (user.role == 'ca') ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.upload),
                  label: 'Upload',
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
              ] else if (user.role == 'viewer') ...[
                const NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ] else ...[
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
    } else if (user.role == 'ca') {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const CertificateCreateScreen();
      }
    } else if (user.role == 'recipient') {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const RecipientUploadScreen();
      }
    } else if (user.role == 'viewer') {
      if (index == 0) {
        return const ViewerDashboardScreen();
      }
      if (index == 1) {
        return const SupportUsScreen();
      }
    } else {
      if (index == 0) {
        return const DashboardScreen();
      }
      if (index == 1) {
        return const SupportUsScreen();
      }
    }
    return const Center(child: Text('Page Placeholder'));
  }
}
