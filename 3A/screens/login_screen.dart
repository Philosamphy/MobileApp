import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

/// 登录界面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo和标题
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? '欢迎回来' : '创建账户',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? '请登录您的账户' : '请填写以下信息创建账户',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 邮箱输入框
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱地址',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // 密码输入框
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 24),

                  // 登录/注册按钮
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return ElevatedButton(
                        onPressed: authService.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? '登录' : '注册',
                                style: const TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 错误信息显示
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      if (authService.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            authService.error!,
                            style: TextStyle(color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),

                  // 切换登录/注册模式
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                        authService.clearError();
                      });
                    },
                    child: Text(_isLogin ? '没有账户？点击注册' : '已有账户？点击登录'),
                  ),

                  // 忘记密码链接
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('忘记密码？'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isLogin) {
      success = await authService.signIn(email, password);
    } else {
      // 注册时需要确认密码
      final confirmPassword = await _showConfirmPasswordDialog();
      if (confirmPassword == null) return;

      success = await authService.signUp(email, password, confirmPassword);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? '登录成功！' : '注册成功！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<String?> _showConfirmPasswordDialog() async {
    final confirmPasswordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('确认密码'),
        content: TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '请再次输入密码',
            border: OutlineInputBorder(),
          ),
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = confirmPasswordController.text;
              final error = Validators.validateConfirmPassword(
                password,
                _passwordController.text,
              );

              if (error == null) {
                Navigator.of(context).pop(password);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入您的邮箱地址，我们将发送重置密码的链接。'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '邮箱地址',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final error = Validators.validateEmail(email);

              if (error == null) {
                Navigator.of(context).pop();
                final authService = context.read<AuthService>();
                final success = await authService.resetPassword(email);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('重置密码邮件已发送，请检查您的邮箱'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}
