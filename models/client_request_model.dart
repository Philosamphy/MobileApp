import 'package:cloud_firestore/cloud_firestore.dart';

class ClientRequestModel {
  final String id;
  final String title;
  final String email;
  final String clientId;
  final String clientName;
  final String? certificateUrl;
  final String? signatureUrl;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes; // CA notes

  ClientRequestModel({
    required this.id,
    required this.title,
    required this.email,
    required this.clientId,
    required this.clientName,
    this.certificateUrl,
    this.signatureUrl,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'email': email,
      'clientId': clientId,
      'clientName': clientName,
      'certificateUrl': certificateUrl,
      'signatureUrl': signatureUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
    };
  }

  factory ClientRequestModel.fromMap(Map<String, dynamic> map) {
    return ClientRequestModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      email: map['email'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      certificateUrl: map['certificateUrl'],
      signatureUrl: map['signatureUrl'],
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
    );
  }

  ClientRequestModel copyWith({
    String? id,
    String? title,
    String? email,
    String? clientId,
    String? clientName,
    String? certificateUrl,
    String? signatureUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return ClientRequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      email: email ?? this.email,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
