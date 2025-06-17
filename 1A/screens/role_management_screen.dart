import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/role_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  bool _isLoading = false;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final roleService = Provider.of<RoleService>(context, listen: false);
    final users = await roleService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentUser;
    if (currentUser == null || currentUser.role != 'admin') {
      return const Center(child: Text('Access Denied'));
    }
    final roleService = Provider.of<RoleService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Role Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'The currently logged-in administrator is not shown in the list and cannot modify their own role.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users
                          .where((u) => u.email != currentUser.email)
                          .length,
                      itemBuilder: (context, index) {
                        final filteredUsers = _users
                            .where((u) => u.email != currentUser.email)
                            .toList();
                        final user = filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: user.photoUrl != null
                                          ? NetworkImage(user.photoUrl!)
                                          : null,
                                      child: user.photoUrl == null
                                          ? Text(
                                              user.displayName != null &&
                                                      user
                                                          .displayName!
                                                          .isNotEmpty
                                                  ? user.displayName![0]
                                                  : user.email[0].toUpperCase(),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.displayName ?? 'Unnamed User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            user.email,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Current Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Select new role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: roleService
                                      .getAvailableRoles()
                                      .map((role) => _buildRoleChip(role, user))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleChip(String role, UserModel user) {
    final isSelected = user.role == role;
    if (role == 'viewer') {
      return const SizedBox.shrink();
    }
    return FilterChip(
      label: Text(role.toUpperCase()),
      selected: isSelected,
      onSelected: _isLoading
          ? null
          : (selected) async {
              if (selected && !isSelected) {
                setState(() => _isLoading = true);
                try {
                  await Provider.of<RoleService>(
                    context,
                    listen: false,
                  ).updateUserRole(user.uid, role);
                  await _loadUsers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '用户 ${user.displayName ?? user.email} 的身份已更改为 $role',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('更改身份失败: $e')));
                  }
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
      backgroundColor: Colors.grey.shade200,
      selectedColor: _getRoleColor(role),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      disabledColor: Colors.grey.shade300,
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'ca':
        return Colors.blue;
      case 'client':
        return Colors.green;
      case 'recipient':
        return Colors.orange;
      case 'viewer':
        return Colors.grey;
      default:
        return Colors.black26;
    }
  }
}
