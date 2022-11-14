// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:overlay_support/overlay_support.dart';
// import 'package:flutter/material.dart';

// Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Push Notification Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late int _totalNotifications;
//   late final FirebaseMessaging _messaging;
//   PushNotification? _notificationInfo;
//   void requestAndRegisterNotification() async {
//     // 1. Initialize the Firebase app
//     await Firebase.initializeApp();

//     // 2. Instantiate Firebase Messaging
//     _messaging = FirebaseMessaging.instance;
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // 3. On iOS, this helps to take the user permissions
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//       String? token = await _messaging.getToken();
//       print("The token is " + token!);
//       // For handling the received notifications
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // Parse the message received
//         PushNotification notification = PushNotification(
//           title: message.notification?.title,
//           body: message.notification?.body,
//         );

//         setState(() {
//           _notificationInfo = notification;
//           _totalNotifications++;
//         });
//         if (_notificationInfo != null) {
//           // For displaying the notification as an overlay
//           showSimpleNotification(
//             Text(_notificationInfo!.title!),
//             leading: NotificationBadge(totalNotifications: _totalNotifications),
//             subtitle: Text(_notificationInfo!.body!),
//             background: Colors.cyan.shade700,
//             duration: Duration(seconds: 2),
//           );
//         }
//       });
//     } else {
//       print('User declined or has not accepted permission');
//     }
//   }

//   @override
//   void initState() {
//     requestAndRegisterNotification();
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       PushNotification notification = PushNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//       );
//       setState(() {
//         _notificationInfo = notification;
//         _totalNotifications++;
//       });
//     });

//     _totalNotifications = 0;
//     super.initState();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// class PushNotification {
//   PushNotification({
//     this.title,
//     this.body,
//   });
//   String? title;
//   String? body;
// }

// class NotificationBadge extends StatelessWidget {
//   final int totalNotifications;

//   const NotificationBadge({required this.totalNotifications});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40.0,
//       height: 40.0,
//       decoration: new BoxDecoration(
//         color: Colors.red,
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             '$totalNotifications',
//             style: TextStyle(color: Colors.white, fontSize: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }