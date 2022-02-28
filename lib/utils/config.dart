import 'package:firebase_core/firebase_core.dart';

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message ${message.messageId}');
}*/

class Config {
  static initFirebase() async {
    await Firebase.initializeApp();
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
