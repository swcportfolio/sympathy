import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:numberpicker/numberpicker.dart';

import 'package:sympathy_app/data/hope_time.dart';

import 'package:sympathy_app/page/chat/user_list_page.dart';
import 'package:sympathy_app/utils/edit_controller.dart';

import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/page/setting/setting_page.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/fcm_service.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/constants.dart';

import 'package:sympathy_app/utils/lifecycle_event_handler.dart';
import 'package:sympathy_app/utils/network_check.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/widget.dart';

import 'chat_list_page.dart';
import 'my_user_list_page.dart';

class MainPage extends StatefulWidget {

  final Authorization auth;
  final bool isAutoLogin;

  MainPage(this.auth, this.isAutoLogin);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController nameController         = TextEditingController();
  TextEditingController dateOfBirthController  = TextEditingController();
  TextEditingController hopeTimeController     = TextEditingController();

  final _checkNetwork = CheckNetworkConnection(); // 네트워크 체크
  WebSocketClient webSocketClient;
  int _selectedIndex = 0;
  List _pages;
  bool isTap = true;
  String tokenFcm;
  LoginEdit loginEdit;

  List<String> mainTitle = ['나의 내담자', '내담자 찾기', '상담하기'];

  int gridViewIndex; // 선택된 상담시간 - 초기화를 위한
  final int pageIndexInit = 1; // page value init

  SetHopeTime setHopeTime;// 상담시간 검
  String hopeTime1, hopeTime2;

  bool runOnce = true;

  @override
  void initState() {
    super.initState();

    //네트워크 체크
   _checkNetwork.checkNetWork(context);

   //fcm 토큰 재발급
    if(widget.isAutoLogin)
    {
      FCMService(false).getToken().then((token)
      {
        getFcmToken(token);
      });
    }

    FCMService(true);

    setHopeTime = SetHopeTime('날짜 설정', '날짜 설정', '날짜 설정', '시간 설정', '시간 설정', '시간 설정');
    webSocketClient = WebSocketClient(widget.auth, '', onReceiveData);

    WidgetsBinding.instance.addObserver(  //앱 상태 변화 추적 코드 : 어플리케이션의 생명주기 이벤트를 들을 수 있다.
        LifecycleEventHandler(
            resumeCallBack: () async =>
            {
              runOnce = true,
              print('[LifecycleEventHandler] : resume'),
              webSocketClient.setLifecycleStatus('resume'),
            },

            suspendingCallBack: () async =>
            {
              if(Platform.isIOS)
                {
                  print('[LifecycleEventHandler] : suspending'),
                  webSocketClient.setLifecycleStatus('suspending'),
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
    mainList();
  }

  @override
  Widget build(BuildContext context) {
    runOnce = true;
    print(widget.auth.profileImg);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(mainTitle[_selectedIndex], textScaleFactor:0.9, style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        centerTitle: true,
        actions: [
          Visibility(
            visible: isTap,
            child: IconButton(
                highlightColor: Colors.white,
                color: Colors.white,
                icon: Icon(Icons.search_rounded),
                onPressed: ()=>
                {
                  reset(), // 과거 검색 이력 초기화
                  showModalBottomSheet(isScrollControlled: true, context: context, builder: buildBottomSheet)
                }
            ),
          ),
          IconButton(
              highlightColor: Colors.white,
              color: Colors.white,
              icon: Icon(Icons.perm_identity),
              onPressed: ()=>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage(context, widget.auth, webSocketClient:webSocketClient)))
          )
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
                        child: CircularProgressIndicator(strokeWidth: 5))));
          }

          if(snapshot.data.length == 0) {
            return Container(
                child: Center(
                    child: Text('서버와 연결되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 14))
                )
            );
          }
         return Center(child:_pages[_selectedIndex]);

        },
      ),

      bottomNavigationBar: BottomNavigationBar(
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          selectedItemColor: mainColor,
          unselectedItemColor: doUnselectedItemColor,

          items: <BottomNavigationBarItem>[

            BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset('images/home_n.png', height: 19, width: 19, color: _selectedIndex == 0 ? mainColor : doUnselectedItemColor,),
                ),label:'나의 내담자'),

            BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child:
                  Icon(Icons.search_rounded,size: 25,color: _selectedIndex == 1 ? mainColor : doUnselectedItemColor,)
                 // Image.asset('images/home_n.png', height: 19, width: 19,color: _selectedIndex == 0 ? mainColor : doUnselectedItemColor,),
                ),label:'내담자 찾기'),

            BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset('images/chat_n.png', height: 19, width: 19, color: _selectedIndex == 2 ? mainColor : doUnselectedItemColor),
                ),label:'상담하기'),

          ]),
    );
  }


  ///내담자 검색-showModalBottomSheet
  Widget buildBottomSheet(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, sheetSetState){
      return SingleChildScrollView(
        child: Container(
          color: Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20),)),
            padding: EdgeInsets.only(bottom: bottomPadding(context)),
            child: SizedBox( height: 390,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(padding: const EdgeInsets.fromLTRB(20, 20, 12, 5),
                      child: Text('내담자 검색', textScaleFactor: 1.2),
                    ),

                    Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: SearchInputEdit(controller: nameController, iconData: Icons.assignment_outlined, headText: '이름', hint: '이름를 입력해주세요', type: 'name')),

                    Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          [
                            consultingTime(1, '' , hopeTimeController, sheetSetState),
                          ],
                        )
                    ),

                    Padding(padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                        [
                          TextButton(
                            child: Text("취소", textScaleFactor: 1.0, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                            onPressed: ()
                            {
                              Navigator.pop(context);
                              reset(); // 초기화
                              setState(()
                              {
                                mainList();
                              });
                            },
                          ),

                          TextButton(
                            child: Text("확인", textScaleFactor: 1.0, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                            onPressed: ()
                            {
                              setState(()
                              {
                                Navigator.pop(context);
                                combineTime();
                                mainList();
                              });
                            },
                          )
                        ],
                      ),
                    )
                  ]
              ),
            ),
          ),
        ),
      );
    }
    );
  }

  //bottom navigation Tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      mainList(); // 네비게이션 바 다시 호출
      reset();    // 검색 조건 초기화

      if(index > 1 ) isTap = false; // 채팅화면에서는 검색 버튼이 없다.
      else isTap = true;
    });
  }

  List mainList() {
    return _pages = [
      MyUserListPage(widget.auth, nameController.text, dateOfBirthController.text, hopeTime1,hopeTime2, identification: true, requesterID:widget.auth.userID, status:'R',pageIndexInit:pageIndexInit),
      UserListPage(widget.auth, nameController.text, dateOfBirthController.text, hopeTime1,hopeTime2, identification: false, status: 'N', pageIndexInit:pageIndexInit),
      ChatListPage(auth:widget.auth),
    ];
  }

  /// Sheet bottom
  double bottomPadding(BuildContext ctx) {
    var result = MediaQuery.of(ctx).viewInsets.bottom ?? 0;
    if (result == 0) result = 10;
    return result;
  }

  /// 상담 시간 설정
  consultingTime(int index, String text, TextEditingController controller, StateSetter sheetSetState){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        Row(
          children:
          [
            Expanded(flex:5, child: buildTextBox('시작 시간', Icons.calendar_today_outlined, setHopeTime.dateTime1, sheetSetState, identifier:setHopeTime.identifier_1)),
            Expanded(flex:5, child: buildTextBoxTime(Icons.access_time_outlined, setHopeTime.hourTime1, sheetSetState, identifier:setHopeTime.identifier_1)),
          ],
        ),
        Row(
          children:
          [
            Expanded(flex:5, child: buildTextBox('종료 시간', Icons.calendar_today_outlined, setHopeTime.dateTime2, sheetSetState, identifier:setHopeTime.identifier_2)),
            Expanded(flex:5, child: buildTextBoxTime(Icons.access_time_outlined, setHopeTime.hourTime2, sheetSetState, identifier:setHopeTime.identifier_2)),
          ],
        ),
      ],
    );
  }

  /// 날짜 설정
  Widget buildTextBox(String headText, IconData iconData, String hint, StateSetter sheetSetState, {int identifier}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 19, 0, 5),
          child: Text(headText,textScaleFactor: 0.94, style: TextStyle(color:Colors.black))),

        InkWell(
          onTap: (){
            FocusScope.of(context).unfocus();
            //_showIntegerDialog();

            DatePicker.showDatePicker(context,
                theme: DatePickerTheme(
                    itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:13),
                    doneStyle: TextStyle(color: Colors.black, fontSize: 13),
                    cancelStyle: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                showTitleActions: true,
                maxTime: DateTime(2022, 5, 31), // 31일까지
                minTime:DateTime.now(),
                onChanged: (date) { print('change $date'); },
                onConfirm: (date) { print('confirm $date');
                sheetSetState(() {
                  FocusScope.of(context).unfocus();

                  if(identifier == setHopeTime.identifier_1)
                    setHopeTime.dateTime1 = date.year.toString() +'-'+ date.month.toString() +'-'+ date.day.toString();
                  else if(identifier == setHopeTime.identifier_2)
                    setHopeTime.dateTime2 = date.year.toString() +'-'+ date.month.toString() +'-'+ date.day.toString();

                });
                }, currentTime: DateTime.now(), locale: LocaleType.ko);
          },
          child: Container(
            alignment: Alignment.centerLeft,
            height: 47.0,
            child: Padding(padding: const EdgeInsets.all(8.0),
              child: Row(
                children:
                [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                      child: Icon(iconData, color: mainColor)),
                  Text(hint, textScaleFactor: 0.8, style: TextStyle(color: hint.contains('20')? Colors.black:Colors.grey)),
                ],
              ),),
            decoration: BoxDecoration(border: Border.all( width: 1.0,color: Colors.grey,), borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),),)
      ],
    );
  }

  ///시간 설정
  Widget buildTextBoxTime(IconData iconData, String hint, StateSetter sheetSetState, {int identifier}) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 40, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()
            {
              FocusScope.of(context).unfocus();
              _showIntegerDialog(identifier,sheetSetState);
            },

            child: Container(
              alignment: Alignment.centerLeft,
              height: 47.0,
              child: Padding(padding: const EdgeInsets.all(8.0),
                child: Row(
                  children:
                  [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                        child: Icon(iconData, color: mainColor)),
                    Text(hint!='시간 설정'?'$hint시' : hint, textScaleFactor: 0.8, style: TextStyle(color:hint!='시간 설정'? Colors.black:Colors.grey)),
                  ],
                )),
              decoration: BoxDecoration(border: Border.all( width: 1.0,color: Colors.grey,), borderRadius: BorderRadius.all(Radius.circular(5.0)))))
        ],
      ),
    );
  }

  /// 사간설정- dialog
  Future _showIntegerDialog(int identifier, StateSetter sheetSetState) async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return MediaQuery(
          data:Etc.getScaleFontSize(context, fontSize: 0.9),
          child: NumberPickerDialog.integer(selectedTextStyle: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
              minValue: 10, maxValue: 21, initialIntegerValue: 10, highlightSelectedValue:true, haptics:true,
              decoration:BoxDecoration(borderRadius: BorderRadius.circular(40)),
              title: Row(
                children:
                [
                  Image.asset('check.png',width: 15, height: 15, color: mainColor),
                  SizedBox(width: 10),
                  Text("1시간 단위(10시~21시)",style: TextStyle(fontSize: 14)),
                ],
              ),
              confirmWidget:Text('확인', style: TextStyle(color: mainColor)),
              cancelWidget: Text('취소',style: TextStyle(color: mainColor))),
        );
      },
    ).then((num value){
      if(value != null){
        if(value is int){
          sheetSetState(() {

            if(identifier == setHopeTime.identifier_1)  setHopeTime.hourTime1 = value.toString();
            else if(identifier == setHopeTime.identifier_2)  setHopeTime.hourTime2 = value.toString();

          });
        }
      }
    });
  }

  /// 상담시간 합치기
  void combineTime() {
    if(setHopeTime.dateTime1 != '날짜 설정'){
      if(setHopeTime.hourTime1 == '시간 설정')
      {
        hopeTime1 = setHopeTime.dateTime1;
      }else{
        hopeTime1 = setHopeTime.dateTime1 + ' ' + setHopeTime.hourTime1;
      }
    }

    if(setHopeTime.dateTime2 != '날짜 설정'){
      if(setHopeTime.hourTime2 == '시간 설정')
      {
        hopeTime2 = setHopeTime.dateTime2;
      } else {
        hopeTime2 = setHopeTime.dateTime2 + ' ' + setHopeTime.hourTime2;
      }
    }
  }

  ///FCM token 갱신
  getFcmToken(String token) async{
    var loginData = await client.dioLogin(toMap(token));
    if(loginData.accountType !=null){
      print('Token 갱신 완료');
    }
  }

  Map<String, dynamic> toMap(String tokenFcm) {
    if(tokenFcm != null)
    print('===> 상담사  FCM Token : '+tokenFcm);
    else{
      print('tokenFcm null!!!');
    }
    Map<String, dynamic> toMap = {
      'userID'   : widget.auth.userID,
      'password' : widget.auth.password,
      'fcmToken' : tokenFcm,
    };
    return toMap;
  }

  //검색 초기화
  void reset() {
    nameController.text = '';
    setHopeTime = SetHopeTime('날짜 설정', '날짜 설정', '날짜 설정', '시간 설정', '시간 설정', '시간 설정');
    hopeTime1 = '';
    hopeTime2 ='';
    print('====> 검색 reset 실행');
  }

  //WebSocket 접속
  onReceiveData(receivedMessage){
    print('[ mainFunction WebSocket Connect ]'+receivedMessage);
  }

  // 웹소켓 재연결
  _webSocketReconnect(){
    setState(() {
      print('====> webSocketReconnect');
      mainList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
   // webSocketClient.onClose();
  }
}

