import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب الإذن
  NotificationSettings settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else {
    return; // إذا لم يمنح المستخدم الإذن، يمكنك إنهاء الدالة هنا
  }

  // الحصول على توكن FCM
  // String? token = await messaging.getToken();

  // يمكنك تخزين التوكن في قاعدة بيانات أو في SharedPreferences

  // Set up foreground message listener
}
