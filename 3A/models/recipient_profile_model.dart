import 'package:cloud_firestore/cloud_firestore.dart';

class RecipientProfileModel {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? organization;
  final String? profileImageUrl;
  final bool isActive;

  RecipientProfileModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.address,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.organization,
    this.profileImageUrl,
    this.isActive = true,
  });

  factory RecipientProfileModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RecipientProfileModel(
      id: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      organization: data['organization'],
      profileImageUrl: data['profileImageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'address': address,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'organization': organization,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }

  RecipientProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? organization,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return RecipientProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organization: organization ?? this.organization,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'RecipientProfileModel(id: $id, email: $email, displayName: $displayName, phoneNumber: $phoneNumber, address: $address, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, organization: $organization, profileImageUrl: $profileImageUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipientProfileModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.organization == organization &&
        other.profileImageUrl == profileImageUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        phoneNumber.hashCode ^
        address.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        organization.hashCode ^
        profileImageUrl.hashCode ^
        isActive.hashCode;
  }
}
