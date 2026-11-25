import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class NotificationService {
  static const _key = 'notifications';

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? true;
  }

  /// نادِها بعد تسجيل الدخول لحفظ توكن الجهاز
  static Future<void> init(String uid) async {
    if (!await isEnabled()) return;
    final fm = FirebaseMessaging.instance;
    await fm.requestPermission();
    final token = await fm.getToken();
    if (token != null) await FirestoreService.instance.saveFcmToken(uid, token);
    fm.onTokenRefresh.listen((t) async {
      if (await isEnabled()) FirestoreService.instance.saveFcmToken(uid, t);
    });
  }

  /// تشغيل/إيقاف الإشعارات من الإعدادات
  static Future<void> setEnabled(String uid, bool on) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, on);
    if (on) {
      await init(uid);
    } else {
      await FirebaseMessaging.instance.deleteToken();
      await FirestoreService.instance.saveFcmToken(uid, '');
    }
  }
}