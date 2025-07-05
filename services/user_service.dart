import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// 用户管理服务
class UserService extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取所有用户
  Future<void> fetchUsers() async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      // 模拟用户数据
      _users = [
        User(
          id: '1',
          email: 'admin@example.com',
          role: 'admin',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        User(
          id: '2',
          email: 'user1@example.com',
          role: 'user',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
        User(
          id: '3',
          email: 'manager@example.com',
          role: 'manager',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _setError('获取用户列表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 创建新用户
  Future<bool> createUser(User user) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));

      // 添加到本地列表
      final newUser = user.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _users.add(newUser);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('创建用户失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用户信息
  Future<bool> updateUser(User user) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));

      // 更新本地列表
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('更新用户失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 删除用户
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));

      // 从本地列表移除
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('删除用户失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 根据角色筛选用户
  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  /// 搜索用户
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;

    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) {
      return user.email.toLowerCase().contains(lowercaseQuery) ||
          user.role.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// 获取用户统计信息
  Map<String, int> getUserStats() {
    final stats = <String, int>{};

    for (final user in _users) {
      stats[user.role] = (stats[user.role] ?? 0) + 1;
    }

    return {
      'total': _users.length,
      'admin': stats['admin'] ?? 0,
      'user': stats['user'] ?? 0,
      'manager': stats['manager'] ?? 0,
    };
  }

  /// 批量更新用户角色
  Future<bool> batchUpdateUserRoles(
    List<String> userIds,
    String newRole,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));

      // 更新本地列表
      for (final id in userIds) {
        final index = _users.indexWhere((user) => user.id == id);
        if (index != -1) {
          final user = _users[index];
          _users[index] = user.copyWith(
            role: newRole,
            updatedAt: DateTime.now(),
          );
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('批量更新用户角色失败: $e');
      return false;
    } finally {
      _setLoading(false);
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
