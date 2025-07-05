import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// 认证服务
class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 用户登录
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      // 模拟验证逻辑
      if (email.isEmpty || password.isEmpty) {
        throw Exception('邮箱和密码不能为空');
      }

      if (!email.contains('@')) {
        throw Exception('请输入有效的邮箱地址');
      }

      if (password.length < 6) {
        throw Exception('密码长度至少6位');
      }

      // 模拟登录成功
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        name: email.split('@')[0],
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('登录失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 用户注册
  Future<bool> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      // 模拟验证逻辑
      if (email.isEmpty || password.isEmpty) {
        throw Exception('邮箱和密码不能为空');
      }

      if (!email.contains('@')) {
        throw Exception('请输入有效的邮箱地址');
      }

      if (password.length < 6) {
        throw Exception('密码长度至少6位');
      }

      if (password != confirmPassword) {
        throw Exception('两次输入的密码不一致');
      }

      // 模拟注册成功
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: email.split('@')[0],
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('注册失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 用户登出
  Future<void> signOut() async {
    _setLoading(true);

    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('登出失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 重置密码
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || !email.contains('@')) {
        throw Exception('请输入有效的邮箱地址');
      }

      // 模拟发送重置邮件
      return true;
    } catch (e) {
      _setError('重置密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用户信息
  Future<bool> updateUserInfo(User updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
      notifyListeners();

      return true;
    } catch (e) {
      _setError('更新用户信息失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 修改密码
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('密码不能为空');
      }

      if (newPassword.length < 6) {
        throw Exception('新密码长度至少6位');
      }

      // 模拟密码修改成功
      return true;
    } catch (e) {
      _setError('修改密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 删除账户
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      if (password.isEmpty) {
        throw Exception('请输入密码确认删除');
      }

      // 模拟账户删除成功
      _currentUser = null;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('删除账户失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 检查用户权限
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'admin':
        return _currentUser!.isAdmin;
      case 'manager':
        return _currentUser!.isAdmin || _currentUser!.isManager;
      case 'user':
        return true;
      default:
        return false;
    }
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 清除错误信息
  void clearError() {
    _clearError();
  }
}
