import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static bool notificationsEnabled = true;

  static void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;

    openAppSettings();
  }
}
