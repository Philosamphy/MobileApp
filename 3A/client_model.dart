class CertificateRequest {
  final String id;
  final String recipientName;
  final String recipientEmail;
  final String organization;
  final String purpose;
  final DateTime dateRequested;
  final String? documentUrl;
  final String status; // pending, approved, rejected

  CertificateRequest({
    required this.id,
    required this.recipientName,
    required this.recipientEmail,
    required this.organization,
    required this.purpose,
    required this.dateRequested,
    this.documentUrl,
    this.status = 'pending',
  });
}
