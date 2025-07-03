import 'constants.dart';

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

    if (value.length < AppConstants.minPasswordLength) {
      return '密码长度至少${AppConstants.minPasswordLength}位';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return '密码长度不能超过${AppConstants.maxPasswordLength}位';
    }

    // 检查密码复杂度
    bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!hasUpperCase || !hasLowerCase || !hasDigits) {
      return '密码必须包含大小写字母和数字';
    }

    return null;
  }

  /// 验证用户名
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }

    if (value.length < AppConstants.minUsernameLength) {
      return '用户名长度至少${AppConstants.minUsernameLength}位';
    }

    if (value.length > AppConstants.maxUsernameLength) {
      return '用户名长度不能超过${AppConstants.maxUsernameLength}位';
    }

    // 检查用户名格式
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
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

  /// 验证身份证号
  static String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号';
    }

    final idCardRegex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCardRegex.hasMatch(value)) {
      return '请输入有效的身份证号';
    }

    return null;
  }

  /// 验证URL格式
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入URL';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return '请输入有效的URL';
    }

    return null;
  }

  /// 验证数字范围
  static String? validateNumberRange(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return '请输入数值';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '请输入有效的数字';
    }

    if (number < min || number > max) {
      return '数值必须在$min到$max之间';
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
