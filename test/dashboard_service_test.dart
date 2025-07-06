import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock_firebase.mocks.dart';
import 'package:certificate/services/dashboard_service.dart';
import 'package:certificate/models/document_model.dart';
import 'package:certificate/models/user_model.dart';

void main() {
  late DashboardService dashboardService;

  setUp(() {
    dashboardService = DashboardService();
  });

  test('documents list is initially empty', () {
    expect(dashboardService.documents, isEmpty);
  });

  test('clearError sets error to null', () {
    dashboardService.clearError();
    expect(dashboardService.error, isNull);
  });

  // 由于DashboardService未做依赖注入，涉及Firestore的测试建议后续重构后再mock
}
