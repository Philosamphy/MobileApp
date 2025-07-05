import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_profile_screen.dart';
import 'models/user_model.dart';
import 'utils/validators.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const UserManagementApp());
}

class UserManagementApp extends StatelessWidget {
  const UserManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        title: '用户管理系统',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
          return const UserProfileScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

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
            title: const Text('用户资料'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => authService.signOut(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.email[0].toUpperCase()),
                    ),
                    title: Text(user.email),
                    subtitle: Text('用户ID: ${user.id}'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('邮箱'),
                        subtitle: Text(user.email),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showEditEmailDialog(context, user),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('修改密码'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('删除账户'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () =>
                            _showDeleteAccountDialog(context, authService),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditEmailDialog(BuildContext context, User user) {
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改邮箱'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: '新邮箱地址',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现邮箱修改逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('邮箱修改功能待实现')));
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '当前密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现密码修改逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('密码修改功能待实现')));
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: const Text('确定要删除您的账户吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现账户删除逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('账户删除功能待实现')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
