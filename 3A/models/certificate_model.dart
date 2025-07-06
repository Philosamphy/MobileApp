import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificateStatus { draft, pending, approved, issued, revoked }

class CertificateModel {
  final String id;
  final String title;
  final String recipientId;
  final String recipientName;
  final String recipientEmail;
  final String organization;
  final String purpose;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String? certificateUrl;
  final String issuerId;
  final String issuerName;
  final CertificateStatus status;
  final String? signatureUrl;
  final String? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shareToken;
  final bool isPhysicalDocument;

  CertificateModel({
    required this.id,
    required this.title,
    required this.recipientId,
    required this.recipientName,
    required this.recipientEmail,
    required this.organization,
    required this.purpose,
    required this.issuedDate,
    required this.expiryDate,
    this.certificateUrl,
    required this.issuerId,
    required this.issuerName,
    required this.status,
    this.signatureUrl,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.shareToken,
    this.isPhysicalDocument = false,
  });

  factory CertificateModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CertificateModel(
      id: doc.id,
      title: data['title'] ?? '',
      recipientId: data['recipientId'] ?? '',
      recipientName: data['recipientName'] ?? '',
      recipientEmail: data['recipientEmail'] ?? '',
      organization: data['organization'] ?? '',
      purpose: data['purpose'] ?? '',
      issuedDate: (data['issuedDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      certificateUrl: data['certificateUrl'],
      issuerId: data['issuerId'] ?? '',
      issuerName: data['issuerName'] ?? '',
      status: CertificateStatus.values.firstWhere(
        (e) => e.toString() == 'CertificateStatus.${data['status']}',
        orElse: () => CertificateStatus.draft,
      ),
      signatureUrl: data['signatureUrl'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      shareToken: data['shareToken'],
      isPhysicalDocument: data['isPhysicalDocument'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'organization': organization,
      'purpose': purpose,
      'issuedDate': Timestamp.fromDate(issuedDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'certificateUrl': certificateUrl,
      'issuerId': issuerId,
      'issuerName': issuerName,
      'status': status.toString().split('.').last,
      'signatureUrl': signatureUrl,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'shareToken': shareToken,
      'isPhysicalDocument': isPhysicalDocument,
    };
  }

  CertificateModel copyWith({
    String? id,
    String? title,
    String? recipientId,
    String? recipientName,
    String? recipientEmail,
    String? organization,
    String? purpose,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? certificateUrl,
    String? issuerId,
    String? issuerName,
    CertificateStatus? status,
    String? signatureUrl,
    String? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shareToken,
    bool? isPhysicalDocument,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      organization: organization ?? this.organization,
      purpose: purpose ?? this.purpose,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      status: status ?? this.status,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shareToken: shareToken ?? this.shareToken,
      isPhysicalDocument: isPhysicalDocument ?? this.isPhysicalDocument,
    );
  }
}
