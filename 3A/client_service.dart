import 'client_model.dart';

class ClientService {
  Future<List<CertificateRequest>> fetchMyRequests() async {
    // TODO: Replace with actual API call
    return [];
  }

  Future<void> submitCertificateRequest(CertificateRequest request) async {
    // TODO: API to submit a new certificate request
  }

  Future<List<CertificateRequest>> fetchPendingApprovals() async {
    // TODO: Fetch certificates waiting for client approval
    return [];
  }

  Future<void> approveRequest(String requestId, bool approve, {String? comment}) async {
    // TODO: API call to approve/reject certificate
  }
}
