/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = '数字证书管理系统';
  static const String appVersion = '1.0.0';

  // 用户角色
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  static const String roleManager = 'manager';

  // 权限级别
  static const int permissionRead = 1;
  static const int permissionWrite = 2;
  static const int permissionDelete = 4;
  static const int permissionAdmin = 8;

  // 证书状态
  static const String statusActive = 'active';
  static const String statusExpired = 'expired';
  static const String statusRevoked = 'revoked';
  static const String statusPending = 'pending';

  // 证书类型
  static const String certTypeSSL = 'ssl';
  static const String certTypeCodeSigning = 'code_signing';
  static const String certTypeEmail = 'email';
  static const String certTypeClient = 'client';

  // 颜色主题
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF1976D2;
  static const int accentColor = 0xFF03A9F4;

  // 文本常量
  static const String loginTitle = '登录';
  static const String registerTitle = '注册';
  static const String dashboardTitle = '仪表板';
  static const String roleManagementTitle = '角色管理';
  static const String certificateManagementTitle = '证书管理';

  // 错误消息
  static const String errorNetwork = '网络连接错误';
  static const String errorAuth = '认证失败';
  static const String errorPermission = '权限不足';
  static const String errorUnknown = '未知错误';

  // 成功消息
  static const String successLogin = '登录成功';
  static const String successLogout = '退出成功';
  static const String successSave = '保存成功';
  static const String successDelete = '删除成功';

  // 验证规则
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // API 端点
  static const String apiBaseUrl = 'https://your-api-domain.com/api';
  static const String apiAuth = '/auth';
  static const String apiUsers = '/users';
  static const String apiRoles = '/roles';
  static const String apiCertificates = '/certificates';

  // 本地存储键
  static const String keyUserToken = 'user_token';
  static const String keyUserData = 'user_data';
  static const String keyAppSettings = 'app_settings';
  static const String keyThemeMode = 'theme_mode';

  // 文件路径
  static const String assetsImages = 'assets/images/';
  static const String assetsIcons = 'assets/icons/';
  static const String assetsFonts = 'assets/fonts/';

  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm:ss';
}
