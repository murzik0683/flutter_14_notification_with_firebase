//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_14_notification_with_firebase/notifications_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

////https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/README.md?ysclid=laebz973rs603862509
///https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/lib/main.dart?ysclid=laecj5u0mp918532277
///https://github.com/flutter/flutter/issues/17941?ysclid=lad4lad6vo282642583
///https://firebase.google.com/docs/cloud-messaging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(firebaseMessaging);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channelFire);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: const NotificationPage());
  }
}
