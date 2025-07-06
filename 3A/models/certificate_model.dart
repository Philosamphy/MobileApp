import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// 证书模型类
@immutable
class Certificate {
  final String id;
  final String name;
  final String type;
  final String status;
  final String issuer;
  final String subject;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String serialNumber;
  final String? description;
  final String? ownerId;
  final String? ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Certificate({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.issuer,
    required this.subject,
    required this.issuedDate,
    required this.expiryDate,
    required this.serialNumber,
    this.description,
    this.ownerId,
    this.ownerName,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// 从JSON创建证书对象
  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      issuer: json['issuer'] as String,
      subject: json['subject'] as String,
      issuedDate: DateTime.parse(json['issuedDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      serialNumber: json['serialNumber'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'issuer': issuer,
      'subject': subject,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'serialNumber': serialNumber,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 创建副本
  Certificate copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    String? issuer,
    String? subject,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? serialNumber,
    String? description,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Certificate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      issuer: issuer ?? this.issuer,
      subject: subject ?? this.subject,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      serialNumber: serialNumber ?? this.serialNumber,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 检查证书是否过期
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// 检查证书是否即将过期（30天内）
  bool get isExpiringSoon {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return DateTime.now().isBefore(expiryDate) &&
        expiryDate.isBefore(thirtyDaysFromNow);
  }

  /// 获取证书剩余天数
  int get daysUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return 0;
    }
    return expiryDate.difference(now).inDays;
  }

  /// 获取证书类型显示名称
  String get typeDisplayName {
    switch (type) {
      case AppConstants.certTypeSSL:
        return 'SSL证书';
      case AppConstants.certTypeCodeSigning:
        return '代码签名证书';
      case AppConstants.certTypeEmail:
        return '邮件证书';
      case AppConstants.certTypeClient:
        return '客户端证书';
      default:
        return type;
    }
  }

  /// 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case AppConstants.statusActive:
        return '有效';
      case AppConstants.statusExpired:
        return '已过期';
      case AppConstants.statusRevoked:
        return '已吊销';
      case AppConstants.statusPending:
        return '待审核';
      default:
        return status;
    }
  }

  /// 获取状态颜色
  int get statusColor {
    switch (status) {
      case AppConstants.statusActive:
        return 0xFF4CAF50; // 绿色
      case AppConstants.statusExpired:
        return 0xFFF44336; // 红色
      case AppConstants.statusRevoked:
        return 0xFF9E9E9E; // 灰色
      case AppConstants.statusPending:
        return 0xFFFF9800; // 橙色
      default:
        return 0xFF9E9E9E; // 灰色
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Certificate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Certificate(id: $id, name: $name, type: $type, status: $status)';
  }
}
