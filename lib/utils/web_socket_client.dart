import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:sympathy_app/data/search_default_data.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/save_data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database_helper.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/authorization.dart';

class WebSocketClient {
  final String wsServerUrl = 'ws://106.251.70.71:50006/ws/chat';
  static WebSocketChannel _channel; // websocket 서버에 연결하는데 필요한 도구 - 서버메세지를 수신하거나 서버에 보낼 수 있다.

  FlutterLocalNotificationsPlugin localNotification;
  DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static Function _onReceive;
  static Authorization _auth;
  static String _peerID;
  static String _lifecycleStatus = '';

  static WebSocketClient _instance;
  bool isConnected = false;
  SearchDefaultData searchData;

  bool isSearchData ;

  factory WebSocketClient(Authorization auth, String peerID, Function onReceive) {
    _auth = auth;
    _peerID = peerID;
    _onReceive = onReceive;

    if(_instance == null)
      _instance = WebSocketClient._internal();
    else
      print('[WebSocketClient] instance Not NULl');
    return _instance;
  }

  WebSocketClient._internal()
  {
    // Local Notification 설정
    AndroidInitializationSettings androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings iOSInitialize = IOSInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    InitializationSettings initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    localNotification = FlutterLocalNotificationsPlugin();

    localNotification.initialize(initializationSettings);
    print('====> [WebSocketClient._internal] 실행');
  }

  setLifecycleStatus(lifecycleStatus) {
    _lifecycleStatus = lifecycleStatus;
   // print('[LifecycleEventHandler] : suspending');

    if(_lifecycleStatus == 'resume' && !isConnected)
      {
        print('====> web_socket_client / tryToConnect');
        tryToConnect();
      }
  }

/// webSocket 연결 시
  Future <String> tryToConnect() async {
    if(_channel == null) {
      print('====> [WebSocket] Try to connect : $wsServerUrl');

      try {
        await WebSocket.connect(wsServerUrl).timeout(Duration(milliseconds: 15000)).then((socket) async {
          _channel = IOWebSocketChannel(socket);
          if(_channel == null)
          {
            await Future.delayed(Duration(seconds: 1));
            tryToConnect();
          }
          else {
            _channel.sink.add(ChatData(messageType: 'ENTER', senderID: _auth.userID).toJsonString()); // 서버에 데이터 보내기(enter)
            print('====> [WebSocket] Connected Server');

            _channel.stream.listen((receivedMessage) {
              isConnected = true;
              print('====> [WebSocket] receivedMessage : ' + receivedMessage);

              if(_lifecycleStatus != ''){
                print('====> [WebSocket] lifecycle : ' + _lifecycleStatus);
              }

              ChatData receiveChatData = ChatData.fromString(receivedMessage);
              String oriMessageType = receiveChatData.messageType;
              print('----> oriMessageType : '+oriMessageType);

              if(receiveChatData.messageType == 'IS' || receiveChatData.messageType == 'IE'){
                receiveChatData.messageType = "INPUT";
              }else{
                receiveChatData.messageType = "RECEIVE";
              }


              if (oriMessageType != 'ENTER' )
              {
                if(receiveChatData.messageType != 'INPUT'){
                  if (_peerID == null || _peerID == '' || _lifecycleStatus == 'suspending')
                  {
                    _showNotification(receiveChatData);
                    print('====> _showNotification');
                  }
                  else {
                    _insertChatData(receiveChatData);
                    print('====> _insertChatData');
                  }
                }
              }

              if(_peerID == null && receiveChatData.messageType == 'INPUT') {
                print('----> chat page 아닌곳');
              }else{
                if (_onReceive != null ) _onReceive(receivedMessage);
              }


            },
                onError: (e) async {
                print('[WebSocket] Error : ${e.toString()}');
              },

                onDone: () async {
              print('[WebSocket] Disconnect Server');
              _channel = null;
              isConnected = false;

              if(_lifecycleStatus != 'suspending' && Platform.isIOS)
               {
                 tryToConnect();
               }

            });

          return 'success';
          }
        });
      } catch(e) {
        print('[WebSocket] ' + e.toString());
      }

      if(_channel == null)
      {
        await Future.delayed(Duration(seconds: 2));
        if(_lifecycleStatus != 'suspending'&& Platform.isIOS)
        {
          tryToConnect();
        }
      }
    }
    return 'false';
  }

  void onClose()
  {
    if(_channel != null)
    {
      print('---> webSocket close');
      _channel.sink.close();
      isConnected = false;
    }
  }

  bool getConnectedState()
  {
    return isConnected;
  }

  void onEnd()
  {
    _channel = null;
    isConnected = false;
    _auth.clean();
    _instance = null;
   print('[onEnd] 실행');
  }

  void onSend(ChatData chatData)
  {
    _channel.sink.add(chatData.toJsonString());
  }

  void initData(peerID, Function onReceive)
  {
    _peerID = peerID;
    _onReceive = onReceive;
  }

  void setReceiveCallBack(Function(dynamic) onReceive)
  {
    _onReceive = onReceive;
  }

  void _insertChatData(ChatData chatData) async
  {
    final id = await _dbHelper.insert(chatData.toMapForDB());
    print('inserted row id: $id');
  }

  Future _showNotification(ChatData chatData) async {

    if(chatData.message == endMessage) // 상담 종료메시지
    {
      chatData.message = Etc.parsingEndMessage(chatData.message);
    }

    print('web_socket_client ShowNotification');
    AndroidNotificationDetails androidDetails = new AndroidNotificationDetails('channelId', 'Local Notification', 'This is the description of the Notification, you can write anything', importance: Importance.max, priority: Priority.high);
    IOSNotificationDetails iosDetails = IOSNotificationDetails(presentBadge: true);
    NotificationDetails genderalNotificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(DateTime.now().microsecond, chatData.senderName, chatData.message, genderalNotificationDetails);
  }
}