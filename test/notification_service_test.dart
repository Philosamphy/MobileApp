import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock_firebase.mocks.dart';
import 'package:certificate/services/notification_service.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late NotificationService notificationService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    notificationService = NotificationService();
    // NotificationService未做依赖注入，建议后续重构
  });

  test('notifications list is initially empty', () {
    expect(notificationService.notifications, isEmpty);
  });

  test('unreadCount is initially 0', () {
    expect(notificationService.unreadCount, 0);
  });

  // 由于NotificationService未做依赖注入，涉及Firestore的测试建议后续重构后再mock
}
