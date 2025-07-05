import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String title;
  final String recipientName;
  final String recipientEmail;
  final String recipientId;
  final String issuerName;
  final String issuerId;
  final String organization;
  final String purpose;
  final String status;
  final String? certificateUrl;
  final String? signatureUrl;
  final String? shareToken;
  final DateTime? shareTokenCreatedAt;
  final Map<String, dynamic>? metadata;
  final bool isPhysicalDocument;
  final DateTime createdAt;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final DateTime? updatedAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientId,
    required this.issuerName,
    required this.issuerId,
    required this.organization,
    required this.purpose,
    required this.status,
    this.certificateUrl,
    this.signatureUrl,
    this.shareToken,
    this.shareTokenCreatedAt,
    this.metadata,
    this.isPhysicalDocument = false,
    required this.createdAt,
    required this.issuedDate,
    required this.expiryDate,
    this.updatedAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      recipientName: map['recipientName'] ?? '',
      recipientEmail: map['recipientEmail'] ?? '',
      recipientId: map['recipientId'] ?? '',
      issuerName: map['issuerName'] ?? '',
      issuerId: map['issuerId'] ?? '',
      organization: map['organization'] ?? '',
      purpose: map['purpose'] ?? '',
      status: map['status'] ?? '',
      certificateUrl: map['certificateUrl'],
      signatureUrl: map['signatureUrl'],
      shareToken: map['shareToken'],
      shareTokenCreatedAt: map['shareTokenCreatedAt'] != null
          ? (map['shareTokenCreatedAt'] as Timestamp).toDate()
          : null,
      metadata: map['metadata'],
      isPhysicalDocument: map['isPhysicalDocument'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      issuedDate: (map['issuedDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'recipientId': recipientId,
      'issuerName': issuerName,
      'issuerId': issuerId,
      'organization': organization,
      'purpose': purpose,
      'status': status,
      'certificateUrl': certificateUrl,
      'signatureUrl': signatureUrl,
      'shareToken': shareToken,
      'shareTokenCreatedAt': shareTokenCreatedAt != null
          ? Timestamp.fromDate(shareTokenCreatedAt!)
          : null,
      'metadata': metadata,
      'isPhysicalDocument': isPhysicalDocument,
      'createdAt': Timestamp.fromDate(createdAt),
      'issuedDate': Timestamp.fromDate(issuedDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? recipientName,
    String? recipientEmail,
    String? recipientId,
    String? issuerName,
    String? issuerId,
    String? organization,
    String? purpose,
    String? status,
    String? certificateUrl,
    String? signatureUrl,
    String? shareToken,
    DateTime? shareTokenCreatedAt,
    Map<String, dynamic>? metadata,
    bool? isPhysicalDocument,
    DateTime? createdAt,
    DateTime? issuedDate,
    DateTime? expiryDate,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientId: recipientId ?? this.recipientId,
      issuerName: issuerName ?? this.issuerName,
      issuerId: issuerId ?? this.issuerId,
      organization: organization ?? this.organization,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      shareToken: shareToken ?? this.shareToken,
      shareTokenCreatedAt: shareTokenCreatedAt ?? this.shareTokenCreatedAt,
      metadata: metadata ?? this.metadata,
      isPhysicalDocument: isPhysicalDocument ?? this.isPhysicalDocument,
      createdAt: createdAt ?? this.createdAt,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
