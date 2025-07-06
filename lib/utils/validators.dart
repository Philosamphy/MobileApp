/// 表单验证工具类
class Validators {
  /// 验证邮箱格式
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }

    return null;
  }

  /// 验证密码强度
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码长度至少6位';
    }

    if (value.length > 20) {
      return '密码长度不能超过20位';
    }

    return null;
  }

  /// 验证确认密码
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }

    if (value != password) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  /// 验证必填字段
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  /// 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }

    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号';
    }

    return null;
  }

  /// 验证字符串长度
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }

    if (value.length < minLength) {
      return '$fieldName长度至少$minLength位';
    }

    if (value.length > maxLength) {
      return '$fieldName长度不能超过$maxLength位';
    }

    return null;
  }
}
