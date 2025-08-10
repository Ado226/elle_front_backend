import '../services/payment_service.dart';
import '../services/notification_service.dart';
import '../services/loyalty_service.dart';

class AppInitialization {
  static Future<void> initialize() async {
    // Initialize sample data for all services
    await Future.wait([
      PaymentService.createSampleData(),
      NotificationService.createSampleNotifications(),
      LoyaltyService.createSampleData(),
    ]);
  }
}