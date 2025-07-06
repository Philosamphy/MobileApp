import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock_firebase.mocks.dart';
import 'package:certificate/services/role_service.dart';
import 'package:certificate/models/user_model.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late RoleService roleService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    roleService = RoleService();
    // 这里RoleService未做依赖注入，建议后续重构
  });

  test('getAvailableRoles returns all roles', () {
    final roles = roleService.getAvailableRoles();
    expect(
      roles,
      containsAll(['admin', 'ca', 'client', 'recipient', 'viewer']),
    );
  });

  test('getRoleDescription returns correct description', () {
    expect(roleService.getRoleDescription('admin'), contains('administrator'));
    expect(
      roleService.getRoleDescription('ca'),
      contains('Certificate Authority'),
    );
  });

  test('getRolePermissionList returns correct permissions', () {
    expect(
      roleService.getRolePermissionList('admin'),
      contains('manage_users'),
    );
    expect(roleService.getRolePermissionList('viewer'), contains('read'));
  });

  // getAllUsers和updateUserRole建议重构RoleService支持依赖注入后再mock
}
