import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';

///// Канал локальный
const AndroidNotificationChannel channelLocal = AndroidNotificationChannel(
    'chanel_id', 'chanel_title',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('sound'),
    enableLights: true);

class LocalNotificationService {
  LocalNotificationService();

  final localNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> initialize() async {
    await configureLocalTimeZone();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('ic_launcher');
    DarwinInitializationSettings iosinInitializationSettings =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestSoundPermission: true,
            requestBadgePermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosinInitializationSettings);

    await localNotificationService.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

//инициализация базы часовых поясов и локального часового пояса
//необходимо для уведомления на 8 утра

  static Future configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print(timeZoneName);
  }

// детали уведомления
  Future<NotificationDetails> notificationDetails() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelLocal.id, channelLocal.name,
      channelDescription: channelLocal.description,
      sound: const RawResourceAndroidNotificationSound('sound'),
      //ongoing: true,
      //sound: UriAndroidNotificationSound("assets/sounds/sound.mp3"),
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      color: Colors.blueAccent,
      icon: '@drawable/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_launcher'),
      enableLights: true,
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(presentSound: true, sound: 'sound');
    return NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
  }

///////////////////////////////////////////////////////////////////////////////////////////////////
////простое уведомление по нажатию на кнопку
  Future<void> showNotification({
    required int id,
    required String name,
    String? body,
  }) async {
    final details = await notificationDetails();
    await localNotificationService.show(
      id,
      name,
      body,
      details,
    );
  }

///////////////////////////////////////////////////////////////////////////////////////////////////
  /// уведомление с задержкой времени
  Future<void> showScheduleNotification({
    required int id,
    required String name,
    String? body,
    required int seconds,
  }) async {
    final details = await notificationDetails();
    await localNotificationService.zonedSchedule(
        id,
        name,
        body,
        tz.TZDateTime.from(
            DateTime.now().add(Duration(seconds: seconds)), tz.local),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//// ежедневное уведомление с showDialog (в init запускается при загрузке)
  Future<void> showDailyNotification(
    BuildContext context, {
    required int id,
    required String name,
    required String body,
  }) async {
    final details = await notificationDetails();
    await localNotificationService.periodicallyShow(
        id, name, body, RepeatInterval.daily, details,
        androidAllowWhileIdle: true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: const Color(0xFFF9E9FC),
          title: Stack(
            children: [
              Image.asset(
                'assets/images/butterflay.png',
                height: 170,
              ),
              Column(
                children: [
                  Text(
                    ' Ежедневное напоминание ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.purple.shade900,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ' "Выделить полчаса \n на занятия \n программированием" ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.purple.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ОК',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

///////////////////////////////////////////////////////////////////////////////
//// уведомление каждый час
  Future<void> showHourlyNotification({
    required int id,
    required String name,
    required String body,
  }) async {
    final details = await notificationDetails();
    await localNotificationService.periodicallyShow(
        id, name, body, RepeatInterval.hourly, details,
        androidAllowWhileIdle: true);
  }

///////////////////////////////////////////////////////////////////////////////
//// уведомление с нагрузкой
  Future<void> showNotificationWithDetails({
    required int id,
    required String name,
    required String body,
    required String payload,
  }) async {
    final details = await notificationDetails();
    await localNotificationService.show(
      id,
      name,
      body,
      details,
      payload: payload,
    );
  }

////////////////////////////////////////////////////////////////////////////////////
//// уведомление  с выбором времени, сработает один раз. чтобы повтрорялось каждый день в выбранное время DateTimeComponents.time
  TimeOfDay selectedTime = TimeOfDay.now();
  Future<void> showNotificationsDailyAtChosenTime(
    BuildContext context, {
    required int id,
    required String name,
    required String body,
  }) async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    //выбор времени
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    //newTime == null, если пользователь при выборе времени нажмет Отмена,
    //иначе уведомления будут показываться в выбранное время
    if (newTime != null) {
      selectedTime = newTime;

      print(newTime);
      final details = await notificationDetails();
      await localNotificationService.zonedSchedule(
          id,
          name,
          body,
          nextInstanceOfChosenTime(
              Time(selectedTime.hour, selectedTime.minute)),
          details,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: const Color(0xFFF2D7F6),
            /* ${newTime.format(context)} 
            https://stackoverflow.com/questions/61089587/how-to-format-timeofday-to-string-in-flutter
            https://www.technicalfeeder.com/2022/02/flutter-convert-timeofday-to-24-hours-format/ */
            title: Text(
              'Напоминание на ${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')} запланировано',
              textAlign: TextAlign.center,
            ),
            //content: const Text(''),
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
    }
  }

  //рассчёт следующего времени для ежедневного уведомления в выбранное время
  tz.TZDateTime nextInstanceOfChosenTime(Time selectedTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

////////////////////////////////////////////////////////////////////////////////////////////////
//// уведомление на 8 утра по нажатию на кнопку, сработает один раз. чтобы повтрорялось каждый день в выбранное время DateTimeComponents.time
  Future<void> showNotificationsDailyAt8Time({
    required int id,
    required String name,
    required String body,
  }) async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    final details = await notificationDetails();
    await localNotificationService.zonedSchedule(
        id,
        name,
        body,
        scheduleDaily(const Time(8)), //уведомление на 8 утра способ 1
        //nextInstanceOf8Time(), //уведомление на 8 утра способ 2
        // scheduleWeekly(const Time(8), days: [
        //   DateTime.monday,
        //   DateTime.tuesday
        // ]), // уведомление на 8 утра по понедельникам и вторникам
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

//уведомление на 8 утра способ 1
  tz.TZDateTime scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final now1 = DateTime.now();
    print(now);
    print(now1);

    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    print('Before ${scheduledDate.isBefore(now)}');
    print('+ день ${scheduledDate.add(const Duration(days: 1))}');
    print('scheduledDate $scheduledDate');
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

// уведомление на 8 утра по понедельникам и вторникам
  tz.TZDateTime scheduleWeekly(Time time, {required List<int> days}) {
    tz.TZDateTime scheduledDate = scheduleDaily(time);

    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //уведомления в 8 утра способ 2
  tz.TZDateTime nextInstanceOf8Time() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 8); //here 8 is for 8:00 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

/////////////////////////////////////////////////////////////////////////////////////////////
//// удалить все уведомления
  Future<void> deleteNotification() async {
    localNotificationService.cancelAll();
  }

////////////////////////////////////////////////////////////////////////////////////////////
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onDidReceiveNotificationResponse(payload) async {
    print('details $payload');
    {
      onNotificationClick.add(payload.payload);
    }
  }
  // void onDidReceiveNotificationResponse(
  //     NotificationResponse notificationResponse) async {
  //   final String? payload = notificationResponse.payload;
  //   if (notificationResponse.payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   onNotificationClick.add(payload);
  //   // await Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  //   // );
  // }
}
