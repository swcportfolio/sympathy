import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin localNotification;
  static bool _isShowNotification = false;

  static FCMService _instance;

  factory FCMService(bool isShowNotification) {
    _isShowNotification = isShowNotification;

    if (_instance == null) _instance = FCMService._internal();
    else print('FCMService _instance NOT NULL');
    return _instance;
  }

  FCMService._internal() {
    print('FCMService _internal 실행 ');
    getToken();
    if (Platform.isIOS) checkIOSPermission();

    AndroidInitializationSettings androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings iOSInitialize = IOSInitializationSettings(requestAlertPermission : true, requestSoundPermission : true, requestBadgePermission: true);
    InitializationSettings initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    localNotification = FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (_isShowNotification) {

         // ChatData chatData = ChatData();
         //  chatData.message = message['aps']['alert']['body'];
         //
         // print("====> FCM onMessage: "+message['aps']['alert']['body'].toString());
         // print("====> FCM onMessage: "+message['aps']['alert']['body'].toString());
         //chatData.message = 'FCM onMessage!!!';
         //_showNotification(chatData);
        }
      },

      onLaunch: (Map<String, dynamic> message) async {
       // ChatData chatData = ChatData();
        // chatData.message = message['aps']['alert']['body'];
        // print("====> FCM onResume: "+message['aps']['alert']['body'].toString());
        //chatData.message = 'FCM onLaunch!!!';
       // _showNotification(chatData);

      },

      onResume: (Map<String, dynamic> message) async {
       // ChatData chatData = ChatData();
        // chatData.message = message['aps']['alert']['body'];
        // print("====> FCM onResume: "+message['aps']['alert']['body'].toString());
        //chatData.message = 'FCM onResume!!!';
        //_showNotification(chatData);

      },
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((
        IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    ChatData chatData = ChatData();

    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      chatData.message = data;
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      chatData.message = notification;
    }
    _showNotification(chatData);
    return Future<void>.value();
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  void checkIOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered.listen((
        IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future _showNotification(ChatData chatData) async {
    AndroidNotificationDetails androidDetails = new AndroidNotificationDetails('channelId', 'Local Notification', 'This is the description of the Notification, you can write anything', importance: Importance.max, priority: Priority.high);
    IOSNotificationDetails iosDetails = IOSNotificationDetails(sound: 'default');
    NotificationDetails genderalNotificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // await localNotification.show(0, chatData.senderName, chatData.message, genderalNotificationDetails);
    await localNotification.show(DateTime.now().microsecond, chatData.senderName, chatData.message, genderalNotificationDetails);
  }
}