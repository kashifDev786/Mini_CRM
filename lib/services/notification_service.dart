import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permissions
    await _firebaseMessaging.requestPermission();

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from background: ${message.data}");
    });
  }
}
