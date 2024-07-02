import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/count_msg.dart';
import 'package:sympathy_app/data/search_default_data.dart';

import 'package:sympathy_app/utils/database_helper.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/fcm_service.dart';
import 'package:sympathy_app/utils/lifecycle_event_handler.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/chat_list_item.dart';
import 'package:sympathy_app/utils/constants.dart';

import '../setting/setting_page.dart';
/// ChatListPage
class ChatListPage extends StatefulWidget {

  final Authorization auth;
  ChatListPage({this.auth});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  SearchDefaultData searchData;
  List<ChatData> chatDataList = [];
  List<ChatData> newChatDataList = [];
  ScrollController _scrollController = ScrollController();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  DatabaseHelper _dbHelper;
  WebSocketClient webSocketClient;
  String lastMessageDT;
  String satisfaction; // 만족도 검사 완료? 미완료?

  int pageIndex = 1;
  UserDetails userDetails = UserDetails();

  @override
  void initState() {
    super.initState();

    _dbHelper = DatabaseHelper.instance;
    webSocketClient = WebSocketClient(widget.auth, '', onReceiveData);
    searchData = SearchDefaultData(widget.auth);


    _scrollController.addListener(() { // page Scroll
      if(_scrollController.offset == _scrollController.position.maxScrollExtent){
        if(chatDataList.length % 10 == 0)
          {
            ++pageIndex;
            print('====> pageCount : '+ pageIndex.toString());
            _refreshList();
          }
      }
    });

    _getSenderName();// 자신 이름 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
              children: [
                FutureBuilder(
                  future: _selectChatData(),
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
                              child: SizedBox(height: 40.0, width: 40.0,
                                  child: CircularProgressIndicator(strokeWidth: 5))));
                    }

                    if (snapshot.connectionState == ConnectionState.done)
                    {
                      if(pageIndex == 1)
                      {
                        chatDataList = snapshot.data;
                      }
                      else{
                        newChatDataList = snapshot.data;
                        chatDataList = new List.from(chatDataList)..addAll(newChatDataList);
                      }
                    }

                    for(ChatData chatData in chatDataList)
                    {
                      print('ChatData : ' + chatData.toJsonString());
                    }

                    return dataEmptyCheck();
                  },
                )
              ]
          )
      ),
    );
  }

 // 데이터 확인 및 builder
  Widget dataEmptyCheck() {
    if (chatDataList.isEmpty) {
      return Center(
        child: Text('상담사가 연결되면 공감 앱에서 채팅으로 연락드리겠습니다.',textScaleFactor: 1.0, softWrap: true),
      );
    } else {
      return ListView.builder(
                controller: _scrollController,
                itemCount: chatDataList.length,
                padding: EdgeInsets.only(top: 1), // EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0),
                itemBuilder: (BuildContext context, int index)
                {
                  return ChatListItem(chatDataList[index], index, widget.auth, _onBackCallback,
                    callback:()=>commitSatisfaction(), checkCountMessage:disabledCountMessage(chatDataList[index].message), senderName:userDetails.name);
                }
            );
    }
  }
  void onReceiveData(receivedMessage) { // 상대로부터 chat 데이터를 받았을때
    print('ChatListPageReceivedMessage : ' + receivedMessage);
    if(mounted)
    {
      setState(() {
        searchData.pageIndex = 1;
      });
    }
  }

  Future<void> _onBackCallback() async {
    webSocketClient.initData('', onReceiveData);

    print('[_onBack Callback] 실행');
    setState(() {
      searchData.pageIndex = 1;
    });
  }

  Future<Null> _refreshList() async {
    setState(() {
      searchData.pageIndex = 1;
    });

    return null;
  }

  Future<List<ChatData>> _selectChatData() async {
    lastMessageDT = '';

    String query = 'SELECT groupID, MAX(sendDT) AS sendDT FROM tb_chat_data GROUP BY groupID';
    final List<Map<String, dynamic>> rows = await _dbHelper.rawQuery(query);

    if(rows.length > 0)
      searchData.data = jsonEncode(rows);  // searchData? 유저 데이터?

    print('====> searchData : ${searchData.data}');

    return await client.getChatRecentDataList(searchData, pageIndex);
  }

  // 만족도 검사 완료 확인
  void commitSatisfaction()  {
      setState(() { });
      searchData.pageIndex = 1;
  }


  // 종료된 채팅 알림숫자 제외 및 상담종료 meg parsing
  CheckCountMessage disabledCountMessage(String message){
    CheckCountMessage _countMessage = CheckCountMessage();

    if(message == endMessage) {
      _countMessage.message  = Etc.parsingEndMessage(message);  // 종료 메시지 파싱
      _countMessage.disabled = false;

      return _countMessage;
    }
    else{
      _countMessage.message  = message;
      _countMessage.disabled = true;

      return _countMessage;
    }
  }
  _getSenderName() async{
    userDetails = await client.getUserDetails(widget.auth.userID, widget.auth.account);
  }
}
