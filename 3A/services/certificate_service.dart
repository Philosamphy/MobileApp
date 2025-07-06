import 'package:flutter/foundation.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import '../models/certificate_model.dart';
import '../utils/constants.dart';

/// 证书管理服务
class CertificateService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Certificate> _certificates = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Certificate> get certificates => _certificates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取所有证书
  Future<void> fetchCertificates() async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection('certificates')
          .orderBy('createdAt', descending: true)
          .get();

      _certificates = querySnapshot.docs
          .map((doc) => Certificate.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      _setError('获取证书列表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 根据ID获取证书
  Future<Certificate?> getCertificateById(String id) async {
    try {
      final doc = await _firestore.collection('certificates').doc(id).get();
      if (doc.exists) {
        return Certificate.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      _setError('获取证书详情失败: $e');
      return null;
    }
  }

  /// 创建新证书
  Future<bool> createCertificate(Certificate certificate) async {
    _setLoading(true);
    _clearError();

    try {
      final docRef = await _firestore
          .collection('certificates')
          .add(certificate.toJson());

      // 添加到本地列表
      final newCertificate = certificate.copyWith(id: docRef.id);
      _certificates.insert(0, newCertificate);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('创建证书失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新证书
  Future<bool> updateCertificate(Certificate certificate) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore
          .collection('certificates')
          .doc(certificate.id)
          .update(certificate.toJson());

      // 更新本地列表
      final index = _certificates.indexWhere((c) => c.id == certificate.id);
      if (index != -1) {
        _certificates[index] = certificate;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('更新证书失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 删除证书
  Future<bool> deleteCertificate(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('certificates').doc(id).delete();

      // 从本地列表移除
      _certificates.removeWhere((c) => c.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('删除证书失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 根据状态筛选证书
  List<Certificate> getCertificatesByStatus(String status) {
    return _certificates.where((cert) => cert.status == status).toList();
  }

  /// 根据类型筛选证书
  List<Certificate> getCertificatesByType(String type) {
    return _certificates.where((cert) => cert.type == type).toList();
  }

  /// 获取即将过期的证书（30天内）
  List<Certificate> getExpiringCertificates() {
    return _certificates.where((cert) => cert.isExpiringSoon).toList();
  }

  /// 获取已过期的证书
  List<Certificate> getExpiredCertificates() {
    return _certificates.where((cert) => cert.isExpired).toList();
  }

  /// 搜索证书
  List<Certificate> searchCertificates(String query) {
    if (query.isEmpty) return _certificates;

    final lowercaseQuery = query.toLowerCase();
    return _certificates.where((cert) {
      return cert.name.toLowerCase().contains(lowercaseQuery) ||
          cert.subject.toLowerCase().contains(lowercaseQuery) ||
          cert.issuer.toLowerCase().contains(lowercaseQuery) ||
          cert.serialNumber.toLowerCase().contains(lowercaseQuery) ||
          (cert.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// 获取证书统计信息
  Map<String, int> getCertificateStats() {
    final stats = <String, int>{};

    // 按状态统计
    for (final cert in _certificates) {
      stats[cert.status] = (stats[cert.status] ?? 0) + 1;
    }

    // 按类型统计
    final typeStats = <String, int>{};
    for (final cert in _certificates) {
      typeStats[cert.type] = (typeStats[cert.type] ?? 0) + 1;
    }

    return {
      'total': _certificates.length,
      'active': stats[AppConstants.statusActive] ?? 0,
      'expired': stats[AppConstants.statusExpired] ?? 0,
      'revoked': stats[AppConstants.statusRevoked] ?? 0,
      'pending': stats[AppConstants.statusPending] ?? 0,
      'expiringSoon': getExpiringCertificates().length,
      'ssl': typeStats[AppConstants.certTypeSSL] ?? 0,
      'codeSigning': typeStats[AppConstants.certTypeCodeSigning] ?? 0,
      'email': typeStats[AppConstants.certTypeEmail] ?? 0,
      'client': typeStats[AppConstants.certTypeClient] ?? 0,
    };
  }

  /// 批量更新证书状态
  Future<bool> batchUpdateStatus(
    List<String> certificateIds,
    String newStatus,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final batch = _firestore.batch();

      for (final id in certificateIds) {
        final docRef = _firestore.collection('certificates').doc(id);
        batch.update(docRef, {
          'status': newStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();

      // 更新本地列表
      for (final id in certificateIds) {
        final index = _certificates.indexWhere((c) => c.id == id);
        if (index != -1) {
          final cert = _certificates[index];
          _certificates[index] = cert.copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
          );
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('批量更新状态失败: $e');
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
