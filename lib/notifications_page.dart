import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_14_notification_with_firebase/local_notification_service.dart';
import 'package:flutter_14_notification_with_firebase/second_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:async/async.dart';

// /// Канал firebase
// const AndroidNotificationChannel channelFire = AndroidNotificationChannel(
//   'chanel_id_fire',
//   'chanel_title_fire',
//   importance: Importance.high,
//   playSound: true,
//   sound: RawResourceAndroidNotificationSound('fire'),
//   enableLights: true,
// );

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> firebaseMessaging(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final LocalNotificationService service;

  bool remindMe = false;

  @override
  void initState() {
    super.initState();
    service = LocalNotificationService();
    service.initialize();
    listenToNotification();

    service.showScheduleNotification(
      id: 5,
      name: 'Добро пожаловать!',
      body: '',
      seconds: 3,
    );
    service.showDailyNotification(
      context,
      id: 6,
      name: 'Ежедневное напоминание',
      body: 'Выделить полчаса на занятия программированием',
    );

    /////////////////////////////////////////////////////////////////
    /// Firebase
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? androidNotification = message.notification?.android;
    //   if (notification != null && androidNotification != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //             android: AndroidNotificationDetails(
    //                 channelFire.id, channelFire.name,
    //                 color: Colors.redAccent,
    //                 playSound: true,
    //                 sound: const RawResourceAndroidNotificationSound('fire'),
    //                 icon: '@drawable/heart',
    //                 largeIcon:
    //                     const DrawableResourceAndroidBitmap('@drawable/cat'),
    //                 enableLights: true)));
    //     showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text(notification.title.toString()),
    //             content: SingleChildScrollView(
    //                 child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   notification.body.toString(),
    //                   textAlign: TextAlign.center,
    //                   style: const TextStyle(
    //                       fontSize: 22,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.purple),
    //                 ),
    //               ],
    //             )),
    //             actions: [
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 },
    //                 child: Text(
    //                   'ОК',
    //                   style: TextStyle(
    //                       fontSize: 20,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.purple.shade900),
    //                 ),
    //               ),
    //             ],
    //           );
    //         });
    //   }
    // });
    // /////// Что делает этот код?
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? androidNotification = message.notification?.android;
    //   if (notification != null && androidNotification != null) {
    //     showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text(notification.title.toString()),
    //             content: SingleChildScrollView(
    //                 child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [Text(notification.body.toString())],
    //             )),
    //           );
    //         });
    //   }
    // });
  }

  Timer? _timer;
  int _start = 5;
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (_) {
        if (_start == 0) {
          setState(() {
            _timer!.cancel();
            _start = 5;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: SingleChildScrollView(
          child: SizedBox(
            height: 550,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                      onPressed: () {
                        service.showNotification(
                          id: 0,
                          name: 'Простое уведомление по нажатию на кнопку',
                          //body: 'Пора пить чай',
                        );
                      },
                      heroTag: 1,
                      icon: const Icon(Icons.notifications),
                      label: const Text('Простое уведомление Show'),
                      backgroundColor: Colors.purple.shade200),
                  FloatingActionButton.extended(
                      onPressed: () {
                        service.showScheduleNotification(
                            id: 1,
                            name: 'Вы нажали кнопку 5 секунд назад',
                            //body: '',
                            seconds: 5);
                      },
                      heroTag: 2,
                      label: const Text('Duration 5 sec zonedSchedule'),
                      backgroundColor: Colors.purple.shade300),
                  FloatingActionButton.extended(
                    onPressed: () {
                      service.showHourlyNotification(
                          id: 2,
                          name: 'Напоминание каждый час',
                          body:
                              'Ты помнишь, что нужно заняться программированием?');
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: const Color(0xFFF2D7F6),
                            title: const Text('Напоминание каждый час'),
                            content: const Text(
                              ' "Ты помнишь, что нужно заняться программированием?" ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'ОК',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    heroTag: 3,
                    label: const Text(
                      'Каждый час periodicallyShow',
                    ),
                    backgroundColor: Colors.purple.shade400,
                  ),
                  FloatingActionButton.extended(
                      onPressed: () {
                        service.showNotificationWithDetails(
                            id: 3,
                            name: 'Нажми сюда!',
                            body: '',
                            payload: 'Пора кормить котенка!');
                      },
                      heroTag: 4,
                      label: const Text('Уведомление с переходом payLoad'),
                      backgroundColor: Colors.purple.shade500),
                  FloatingActionButton.extended(
                      onPressed: () {
                        service.showNotificationsDailyAt8Time(
                          id: 7,
                          name: 'Запланированное уведомление',
                          body: 'Пора заняться спортом!!!',
                        );
                        final snackBar = SnackBar(
                            content: const Text(
                              'Напоминание на 8 утра запланировано!',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.purple.shade600);
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      },
                      heroTag: 5,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Уведомление на 8 утра'),
                      backgroundColor: Colors.purple.shade700),
                  FloatingActionButton.extended(
                      onPressed: () {
                        service.showNotificationsDailyAtChosenTime(context,
                            id: 9,
                            name: 'Напоминание на выбранное время',
                            body: 'Вспомни, что нужно сделать!))');
                      },
                      heroTag: 7,
                      label: const Text('Выбери время для уведомления'),
                      backgroundColor: Colors.purple.shade800),
                  FloatingActionButton.extended(
                    onPressed: () {
                      service.deleteNotification();
                    },
                    label: const Text('Удалить все уведомления'),
                    heroTag: 6,
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple.shade200)),
                    onPressed: () {},
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.all(0),
                      value: remindMe,
                      title: Text(
                        remindMe ? 'Запланировано!' : 'Запланируй уведомление!',
                        style: const TextStyle(color: Colors.white),
                      ),
                      //// функция словить появление уведомления при выборе времени????
                      ////https://translated.turbopages.org/proxy_u/en-ru.ru.6856b561-637346c2-eda58e55-74722d776562/https/stackoverflow.com/questions/53393969/flutter-how-to-best-practice-make-a-countdown-widget
                      onChanged: (newValue) async {
                        _startTimer();
                        setState(() {
                          _start = 5;
                          if (newValue) {
                            service.showNotification(
                              id: 10,
                              name: 'Простое уведомление по нажатию на кнопку',
                              //body: 'Пора пить чай',
                            );

                            remindMe = newValue;
                            print('remindMe $remindMe');
                            print('newValue $newValue');

                            RestartableTimer(Duration(seconds: 5), (() {
                              setState(() {
                                remindMe = false;
                                newValue = false;
                                print('new remindMe $remindMe');
                                print('new newValue $newValue');
                              });
                            }));
                          }
                        });
                      },
                      // onChanged: (newValue) async {
                      //   setState(() {
                      //     startTimer();
                      //     remindMe = newValue;
                      //     print('remindMe $remindMe');
                      //     print('newValue $newValue');
                      //     newValue
                      //         ? service.showNotification(
                      //             id: 10,
                      //             name:
                      //                 'Простое уведомление по нажатию на кнопку',
                      //             //body: 'Пора пить чай',
                      //           )
                      //         : Future.delayed(const Duration(seconds: 5))
                      //             .then((_) {
                      //             setState(() {
                      //               remindMe = false;
                      //               newValue = false;
                      //               print('new remindMe $remindMe');
                      //               print('new newValue $newValue');
                      //             });
                      //           });
                      //   });
                      // },
                    ),
                  ),
                  Text("$_start")
                ]),
          ),
        )),
      )),
    );
  }

  void listenToNotification() {
    service.onNotificationClick.stream.listen(onNotificationListener);
  }

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('payload $payload');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => SecondScreen(payload: payload))));
    }
  }
}
