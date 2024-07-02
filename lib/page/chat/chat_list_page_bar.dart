import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/fcm_service.dart';
import 'package:sympathy_app/utils/lifecycle_event_handler.dart';
import 'package:sympathy_app/utils/network_check.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';

import '../setting/setting_page.dart';
import 'chat_list_page.dart';


class ChatListPageBar extends StatefulWidget {

  final Authorization auth;
  final bool isAutoLogin;

  ChatListPageBar(this.auth, this.isAutoLogin);

  @override
  _ChatListPageBarState createState() => _ChatListPageBarState();
}

class _ChatListPageBarState extends State<ChatListPageBar> {

  String tokenFcm;
  WebSocketClient webSocketClient;

  bool runOnce = true;
  final _checkNetwork = CheckNetworkConnection(); // 네트워크 체크

  @override
  void initState() {
    super.initState();

    //네트워크 체크
    _checkNetwork.checkNetWork(context);

    if(widget.isAutoLogin){
      FCMService(false).getToken().then((token) {  tokenFcm = token; }); // 토근 가져오기
      getFcmToken();
    }
    webSocketClient = WebSocketClient(widget.auth, '', onReceiveData);
    FCMService(true);

    WidgetsBinding.instance.addObserver(  //앱 상태 변화 추적 코드 : 어플리케이션의 생명주기 이벤트를 들을 수 있다.
        LifecycleEventHandler(
            resumeCallBack: () async =>
            {
              runOnce = true, //suspending 활성화
              print('[LifecycleEventHandler] : resume'),
              webSocketClient.setLifecycleStatus('resume'),
              if(Platform.isIOS)
                {
                  _webSocketReconnect // resume 상태로 돌아오면 웹소켓 재 연결
                }
            },

            suspendingCallBack: () async =>
            {
              print('[LifecycleEventHandler] : suspending'),
              webSocketClient.setLifecycleStatus('suspending'),
              if(Platform.isIOS)
                {
                  if(runOnce) // 한번만 실행
                    {
                      runOnce = false,
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        webSocketClient.onClose(); // 백그라운드로 홀딩 되면 웹소켓을 끊어 버린다.
                      })

                    }
                }
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Text('상담 목록',textScaleFactor: 0.9, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            backgroundColor: mainColor,
            centerTitle: true,
            actions:
            [
              IconButton(highlightColor: Colors.white, color: Colors.white, icon:  Icon(Icons.help_outline_sharp),
                  onPressed: ()=> Etc.showQuestion(context)),

              IconButton(highlightColor: Colors.white, color: Colors.white, icon: Icon(Icons.perm_identity),
                  onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(context, widget.auth, webSocketClient:webSocketClient)))),
            ],
          ),
          body: FutureBuilder(
            future: webSocketClient.tryToConnect(),
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                return Container(
                    child: Center(
                        child: Text(snapshot.error.toString().replaceFirst('Exception: ', ''), style: TextStyle(color: Colors.white, fontSize: 20.0))
                    )
                );
              }

              if(!snapshot.hasData) {
                return Container(
                    child: Center(
                      // child: Text('Loading...', style: TextStyle(color: Colors.white, fontSize: 25.0),)
                        child: SizedBox(height: 40.0, width: 40.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                            )
                        )
                    )
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                print('[chat list Data bar 실행]');
              }

              if(snapshot.data.length == 0) {
                return Container(
                    child: Center(
                        child: Text('등록된 채팅이 없습니다.',textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 14))
                    )
                );
              }

              return ChatListPage(auth:widget.auth);

            },
          )
      );
  }

  /// FCM Token 갱신
  getFcmToken() async{
    var loginData = await client.dioLogin(toMap(tokenFcm));
    if(loginData.accountType != null){
      print('Token 갱신 완료');
    }
  }
  Map<String, dynamic> toMap(String tokenFcm) {
    Map<String, dynamic> toMap = {
      'userID'   : widget.auth.userID,
      'password' : widget.auth.password,
      'fcmToken' : tokenFcm,
    };
    return toMap;
  }

  void onReceiveData(receivedMessage) {
  print('web socket 연결 중..');
  }

  // 웹소켓 재연결
  _webSocketReconnect(){
    if(mounted){
      setState(() {
        print('====> webSocketReconnect');
      });
    }
  }

}