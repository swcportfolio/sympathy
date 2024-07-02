import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sympathy_app/data/time.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService{

  static NotificationService _instance;
  var _flutterLocalNotificationsPlugin;

  factory NotificationService(){

    if(_instance == null)
      {
        _instance = NotificationService._internal();
      }
    else
      {
        print('NotificationService not null');
      }
    return _instance;
  }

  NotificationService._internal() {

    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(requestAlertPermission : true, requestSoundPermission : true, requestBadgePermission: true);
    var initializationSettings = InitializationSettings(android:initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //1순위 알람
  Future<void> noShowNotification1(TimeNotification time) async {

    AndroidNotificationDetails android = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.max, priority: Priority.high);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android:android, iOS:ios);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().microsecond, '상담사가 알립니다.', '30분 뒤 상담예정입니다.', _setNotiTime(time), detail, androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  //2순위 알람
  Future<void> noShowNotification2(TimeNotification time) async {

    AndroidNotificationDetails android = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.max, priority: Priority.high);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android:android, iOS:ios);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().microsecond, '1차 상담 못하신 내담자 대상입니다.', '30분 뒤 상담예정입니다.', _setNotiTime(time), detail, androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  // 3순위 알람
  Future<void> noShowNotification3(TimeNotification time) async {

    AndroidNotificationDetails android = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.max, priority: Priority.high);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android:android, iOS:ios);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().microsecond, '2차 상담 못하신 내담자 대상입니다.', '30분 뒤 상담예정입니다.', _setNotiTime(time), detail, androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  tz.TZDateTime _setNotiTime(TimeNotification time) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    var scheduledDate = tz.TZDateTime(tz.local, time.year, time.month, time.day, time.hour-1, 30);

    return scheduledDate;
  }

}