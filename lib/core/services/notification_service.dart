import 'package:firebase_messaging/firebase_messaging.dart';
import 'firestore_service.dart';

class NotificationService {
  /// نادِها بعد تسجيل الدخول لحفظ توكن الجهاز (لاستقبال Push من Cloud Functions)
  static Future<void> init(String uid) async {
    final fm = FirebaseMessaging.instance;
    await fm.requestPermission();
    final token = await fm.getToken();
    if (token != null) await FirestoreService.instance.saveFcmToken(uid, token);
    fm.onTokenRefresh.listen((t) => FirestoreService.instance.saveFcmToken(uid, t));
  }
}