import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/search_default_data.dart';
import 'package:sympathy_app/utils/common.dart';
import 'package:sympathy_app/utils/database_helper.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/lifecycle_event_handler.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/utils/constants.dart';

import 'package:sympathy_app/widget/chat_message_item.dart';
import 'package:intl/intl.dart';
//import 'package:keyboard_visibility/keyboard_visibility.dart';

class ChatPage extends StatefulWidget {
  final ChatData chatInfo;
  final Authorization auth;
  final VoidCallback callback;

  ChatPage(this.chatInfo, this.auth, {this.callback});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {

  final String detailedDescription = "선생님께서는 채팅상담 전에 WSRI(근로자 스트레스 반응검사)를 실시하셨습니다. 이 검사는 신체화, 우울, 분노, 직무 4가지 영역에 대한 스트레스 증상을 측정하는 검사입니다.\n일반적으로 스트레스가 높으면 소화불량, 두통 등 신체적 반응이 나타날 수도 있고, 기분이 가라앉고 의욕이 없는 우울감을 느낄 수도 있습니다. 또는 마음대로 안되기 때문에 분노가 높아질 수도 있고, 특히 직장인들은 직무를 수행하는데 있어서 능률이나 집중력이 떨어지기도 합니다.";
  final TextEditingController _textEditingController = TextEditingController();
  final List<ChatMessageItem> _messageItemList = [];
  bool _isComposing = false;
  bool isBot = false;
  List<String> exText = [];
  WebSocketClient webSocketClient;

  DatabaseHelper _dbHelper;
  String _groupID;

  bool _keyboardState = true;
  bool isAccount = false;
  bool isEndChatIcon = false;
  double iosBottomPadding;

  bool sendEndMessage = false;
  FocusNode _focusNode = FocusNode();

  bool isChatKeyboard = true; // 상담사- 상담종료 버튼, 입력버튼 종료시 비활성화 해야됨
  var keyboardVisibilityController = KeyboardVisibilityController();

  bool runOnce = true;
  bool isWriting = false;

  bool runOnceSuspending = true;

  @override
  void initState() {
    super.initState();

    _dbHelper = DatabaseHelper.instance;
    _focusNode.requestFocus();

    _groupID = Common.getGroupID(widget.auth.userID, widget.chatInfo.peerID);
    print('groupID ::'+_groupID);

    _selectChatDataList(); // Chat Data List 조회

    exText.add('WSRI 해석 상담 개요');
    exText.add('[상담 시작] :');
    exText.add('[상담확정] : ');
    exText.add('안녕하세요.');
    exText.add('수고 하셨습니다.');

    webSocketClient = WebSocketClient(widget.auth, widget.chatInfo.peerID, onReceiveData);
    //print('====> senderName :'+widget.chatInfo.senderName);

    if(Platform.isIOS)
    {
      iosBottomPadding = 1.0;
    }else{
      iosBottomPadding = 0.0;
    }

    if(widget.auth.account == 'C'){
      isAccount = true;      // 상담사 자동 message 버튼
      isEndChatIcon = true;  // 상담사의 상담 종료버튼
    }

      keyboardVisibilityController.onChange.listen((bool visible) {
        if(mounted){
          setState(() {
            _keyboardState = visible;

            if(Platform.isIOS)
            {
              if(_keyboardState)
              {
                iosBottomPadding = 0.0;
              }
              else
              {
                iosBottomPadding = 1.0;
              }
            }

          });
        }
      });

    WidgetsBinding.instance.addObserver(  //앱 상태 변화 추적 코드 : 어플리케이션의 생명주기 이벤트를 들을 수 있다.
        LifecycleEventHandler(
          resumeCallBack: () async =>{
            if(mounted)
              {
                runOnce = true,

                if(runOnceSuspending){
                  runOnceSuspending = false,
                  Navigator.pop(context),
                  print('----> pop'),
                }
              }
          },
            suspendingCallBack: () async =>
            {
              print('----> chat page suspending'),
              _writingMessage('IE'), // 쓰기 종료

              runOnceSuspending = true,

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
  }

  @override
  void dispose() {

    runOnce = true;
    _writingMessage('IE');

    for(ChatMessageItem message in _messageItemList)
      if(message.animationController != null) message.animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_keyboardState)
    {
      isBot = false;
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.chatInfo.peerName, textScaleFactor:0.9, style: TextStyle(color: Colors.white)),
          backgroundColor: mainColor,
          iconTheme: IconThemeData(color: Colors.white),
          actions:
          [
            Visibility(visible: isEndChatIcon,
              child: IconButton(icon: Image.asset('out_icon.png',color: Colors.white, height: 20, width: 20,),
                  onPressed: (){
                for(int i=0 ; i<_messageItemList.length ; i++)
                {
                  if( _messageItemList[i].chatData.message == endMessage.substring(5,17))
                  {
                     Etc.newShowSnackBar( '이미 상담이 종료되었습니다.', context);
                     sendEndMessage = false;
                     break;
                   }
                   else
                   {
                     sendEndMessage = true;
                   }
                }
                if(sendEndMessage) deleteDialog('상담을 종료', context);
              }
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(margin: EdgeInsets.only(top: 1),
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (context, index) => _messageItemList[index],
                      itemCount: _messageItemList.length,
                    ),
                  ),

                  Visibility(
                    visible: isWriting,
                    child: Container(
                      height: 60,
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                                      margin: EdgeInsets.only(top: 7, left: 8, right: 8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300],
                                                offset: Offset(0, 0),
                                                blurRadius: 1,
                                                spreadRadius: 1)
                                          ],
                                          color: Colors.white, // Color(0xFF56CA8F1),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero, topRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)
                                          )

                                      ),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.6, minHeight: 30
                                      ),
                                      child: Image.asset('chat.gif',width: 30, height: 30,) ),
                                ],
                              ),
                            ],
                          )
                      ),
                    ),
                  ),

                  Visibility(visible: isChatKeyboard,
                    child: Container(
                      padding:  EdgeInsets.only(bottom: iosBottomPadding),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      child: _buildTextComposer(),
                    ),
                  ),


                  Visibility(visible: isBot,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      child: _buildChatBot(),
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildChatBot(){
    return Scrollbar(
      child: ListView.builder(
          itemCount: exText.length,
          itemBuilder: (BuildContext context, int index){
            return Container(
              color: Color(0xFFE3E3E3),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0.2, 0, 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Color(0xFFECEEF1)),
                    child:  Row(
                      children: [
                        Text(exText[index],style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    onPressed: () {
                      setState(()
                      {
                        if(index == 0){
                          _textEditingController.text = detailedDescription;
                        }else{
                          _textEditingController.text = exText[index];
                        }
                      });
                    },
                  ),
                ),
              ),
            );
          }),
    );
  }

/// 채팅 입력 & 보내기버튼
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Row(
        children: [
          Visibility(
            visible: isAccount,
            child: Flexible(
              flex: 1,
              child: InkWell(
                onTap: ()=>{

                if(isBot)
                {
                  isBot = false
                }else {
                  isBot = true,
                  _keyboardState = false
                },

                  setState((){
                    print('isStateBot::' + isBot.toString());
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    currentFocus.unfocus();

                  })
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Icon(Icons.add, size:35, color: mainColor),
                ),
              ),
            ),
          ),

          Flexible(
            flex: 9,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: MediaQuery(
                      data:Etc.getScaleFontSize(context, fontSize: 0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 4,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.done,
                          controller: _textEditingController,

                          onChanged: (String text) {
                            setState(()
                            {
                                if(text.length > 0)
                                {
                                  if(runOnce)
                                  {
                                    runOnce = false;
                                    _writingMessage('IS');
                                    print('====> text.length > 0');
                                  }else{
                                    print('RunOnce false');
                                  }
                                }else{
                                   runOnce = true;
                                  _writingMessage('IE');
                                }
                            });
                          },
                          onSubmitted: _handleSubmitted,
                          decoration: InputDecoration.collapsed(hintText: '메시지를 입력하세요'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: CupertinoButton(
                        minSize: 0.0,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                        color: Color(0xFF898989),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: Text('전송', textScaleFactor: 0.97, style: TextStyle(color: Colors.white),),
                        onPressed: () => _handleSubmittedExtend('SEND', _textEditingController.text),
                        // onPressed: _isComposing ? () => _handleSubmittedExtend('SEND', _textEditingController.text) : null,
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _handleSubmittedExtend('SEND', text);
  }

  /// Send Message
  void _handleSubmittedExtend(String messageType, String text) {
    _focusNode.requestFocus();

    _textEditingController.clear();

    if(text == '' ) return;
    else if(text == '상담이 종료되었습니다.'){
      Etc.newShowSnackBar('이 메시지는 전송할 수 없습니다.', context);
      return;
    }

    setState(() {
      _isComposing = false;
    });

    ChatData chatData = ChatData(
        message: text,
        groupID: _groupID,
        senderID: widget.auth.userID,
        senderName: widget.chatInfo.senderName,
        receiverID: widget.chatInfo.peerID,
        messageType: messageType,
        sendDT: DateFormat('yyyy-MM-dd HH:mm:ss.S').format(DateTime.now()),
        profileImg: widget.chatInfo.profileImg
    );

    // [onwards]
    // _insertChatData(chatData); // sql insert

    ChatMessageItem message = ChatMessageItem(
        chatData: chatData,
        name: widget.chatInfo.peerName,
        animationController: AnimationController(duration: Duration(milliseconds: 100), vsync: this),
        auth: widget.auth,
        callback: ()=> widget.callback()
    );

    /* [onwards]
    setState(() {
      _messageItemList.insert(0, message); // 자신이 보낸 message insert 후 화면에 뿌리기
    });
    */
    if (messageType == 'SEND') {
      runOnce = true;
      webSocketClient.onSend(chatData); // web socket 으로 데이터 전송
    }

    message.animationController.forward(); // 한칸식 위로 이동(chatItem)
  }

  // 수신된 메세지 데이터
  void onReceiveData(receivedMessage) {

    print('====> Chat Page Received Message : ' + receivedMessage);

    if(receivedMessage == endMessage) // 채팅화면 보는중에 검사 종료메시지가 수신되었을때 채팅입력창 비활성화
      isChatKeyboard = false;

    ChatData receiveChatData = ChatData.fromString(receivedMessage);
    receiveChatData.peerID = widget.chatInfo.peerID;

   if(receiveChatData.messageType == 'IS')
   {
     setState(() {
       print('====> InputStart 받음 ');
       isWriting = true;
     });

   }
   else if(receiveChatData.message == 'IE')
   {
     setState(() {
       print('====> InputEnd 받음');
       isWriting = false;
     });
   }
   else if(receiveChatData.messageType == 'RECEIVE' ||receiveChatData.messageType == 'SEND'){
     if(receiveChatData.groupID != _groupID)
       return;

     print('====> SEND && RECEIVE 받음');

     if(receiveChatData.senderID == widget.auth.userID)
       receiveChatData.messageType = "SEND";

     else
       receiveChatData.messageType = "RECEIVE";

     receiveChatData.profileImg  = widget.chatInfo.profileImg; //리스트에서 가져온 프로필 이미지 저장

     ChatMessageItem messageItem = ChatMessageItem(
         chatData: receiveChatData,
         name: widget.chatInfo.peerName,
         animationController: AnimationController(
             duration: Duration(milliseconds: 100), vsync: this),
         auth: widget.auth,
         chatPageContext: context,
         callback: ()=> widget.callback());

     setState(() {
       _messageItemList.insert(0, messageItem);
       if(receiveChatData.messageType == "RECEIVE"){
         isWriting = false;
       }
     });

     messageItem.animationController.forward();
   }
  }

  // Chat Data List 조회
  void _selectChatDataList() async {
    String lastChatDT = '';
    String where = 'groupID = \'${widget.chatInfo.groupID}\'';
    // String where = 'senderID = \'${widget.chatInfo.peerID}\' OR receiverID = \'${widget.chatInfo.peerID}\'';

    final rows = await _dbHelper.query(where: where, orderBy: 'sendDT ASC');

    String preDate = '';

    if( rows.length > 0 ) {
      // final rows = await _dbHelper.queryAllRows();
      rows.forEach((row) {
        ChatData chatData = ChatData.fromJson(row);
        chatData.profileImg = widget.chatInfo.profileImg;
        chatData.peerID = widget.chatInfo.peerID;

        lastChatDT = chatData.sendDT;

        // 날짜 표시 생성
        if(preDate != chatData.sendDT.substring(0, 10))
        {
          ChatMessageItem messageItem = ChatMessageItem(
            chatData: ChatData(messageType: 'DATE', sendDT: chatData.sendDT.substring(0, 10)), name: widget.chatInfo.peerName,
              chatPageContext:context
              ,callback: ()=> widget.callback());

          _messageItemList.insert(0, messageItem);

          preDate = chatData.sendDT.substring(0, 10);
        }

        if(widget.auth.userID == chatData.senderID)
          chatData.messageType = 'SEND';
        else
          chatData.messageType = 'RECEIVE';


        ChatMessageItem messageItem = ChatMessageItem(
            chatData: chatData,
            name: widget.chatInfo.peerName,
            auth: widget.auth,
            chatPageContext: context,
            callback: ()=> widget.callback()
        );

        _messageItemList.insert(0, messageItem);
      });
    }

    if( widget.chatInfo.unreadCnt != '0' ) {
      await _selectUnreadChatData(lastChatDT);
    }
    setState((){  });
  }

  // 서버에서 읽지 않은 Chat Data List 조회
  Future<void> _selectUnreadChatData(String lastChatDT) async {
    SearchDefaultData searchData = SearchDefaultData(widget.auth);
    searchData.searchStartDate = lastChatDT;
    searchData.groupID = widget.chatInfo.groupID;

    List<ChatData> chatList = await client.getChatDataList(searchData);

    for(ChatData chatData in chatList) {
      chatData.profileImg = widget.chatInfo.profileImg;
      chatData.peerID = widget.chatInfo.peerID;

      ChatMessageItem messageItem = ChatMessageItem(
        chatData: chatData,
        name: widget.chatInfo.peerName,
        auth: widget.auth,
        chatPageContext:context,
        callback: ()=> widget.callback()
      );

      _messageItemList.insert(0, messageItem);

      if(widget.auth.userID == chatData.senderID){
        chatData.messageType = 'SEND';
      }else {
        chatData.messageType = 'RECEIVE';
      }

      final id = await _dbHelper.insert(chatData.toMapForDB());
      print('inserted row id: $id');
    }
  }

  void _updateChatDataReadY() async {
    // String query = '''UPDATE tb_chat_data SET readYN = 'Y' WHERE senderID = '${widget.peerID}' AND readYN = 'N' ''';
    //  ['updated name', '9876', 'some name']);
    // final rowsAffected = await _dbHelper.rawUpdate(query, null);
    // print('updated $rowsAffected row(s)');
  }

  void handlerEndChat(String messageType, String text) {
    // 상담자 쪽에서 상담종료 message 전송
    // 상담종료 message 따로 만들기
    // 내담자 상담종료 승인버튼 따로 만들어주기(클릭시 상담 내용 삭제및 상담설문 이동)

    _handleSubmittedExtend('SEND', text); // 상담사 메세지: 상담이 종료 되었습니다. 아래의 만족도 검사 진행 바랍니다.


/*  상담 종료 버튼 구현 코드
    setState(() {
      _isComposing = false;
    });

    ChatData chatData = ChatData(
        message: endCode,
        groupID: _groupID,
        senderID: widget.auth.userID,
        receiverID: widget.chatInfo.peerID,
        messageType: messageType,
        sendDT: DateFormat('yyyy-MM-dd HH:mm:ss.S').format(DateTime.now()),
        profileImg: widget.chatInfo.profileImg
    );

    _insertChatData(chatData); // sql insert

    ChatMessageItem message = ChatMessageItem(
        chatData: chatData,
        name: widget.chatInfo.peerName,
        animationController: AnimationController(duration: Duration(milliseconds: 100), vsync: this),
        auth: widget.auth
    );

    setState(() {
      _messageItemList.insert(0, message); // 자신이 보낸 message insert 후 화면에 뿌리기
    });

    if (messageType == 'SEND') {
      _webSocketClient.onSend(chatData); // web socket 으로 데이터 전송
      print('End web socket 전송');

    }

    else
      print('End web socket 미전송');

    message.animationController.forward();// 한칸식 위로 이동(chatItem)
*/

  }
/*
    void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId   : 1,
      DatabaseHelper.columnName : 'Mary',
      DatabaseHelper.columnAge  : 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }
  */
  void _insertChatData(ChatData chatData) async {
    final id = await _dbHelper.insert(chatData.toMapForDB());
    print('inserted row id: $id');
  }

  void _delete() async {
    _dbHelper.truncate();
  }

// 상담 종료 버튼 Dialog
  deleteDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline,color: Colors.red,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('상담 종료', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('상담이 종료되면 들어올 수 없습니다.', textScaleFactor: 0.8 ,style: TextStyle(color:Colors.red)),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),

            actions: <Widget>[
              TextButton(
                child: new Text("취소", textScaleFactor:1.1),
                onPressed: () {  Navigator.pop(context); },
              ),

              TextButton(
                child: new Text("확인", textScaleFactor:1.1),
                onPressed: () async{
                  handlerEndChat('SEND', endMessage);
                  Navigator.pop(context);
                  isChatKeyboard = false;
                  isEndChatIcon = false;
                },
              ),

            ],
          );
        });
  }

  // 웹소켓 재연결
  _webSocketReconnect(){
    setState(() {
      print('ChatPage webSocketReconnect');
    });
  }

  // 작성상태 메시지
  void _writingMessage(String message) {
    ChatData chatData = ChatData(
        message: message,
        groupID: _groupID,
        senderID: widget.auth.userID,
        senderName: widget.chatInfo.senderName,
        receiverID: widget.chatInfo.peerID,
        messageType: message,
        sendDT: DateFormat('yyyy-MM-dd HH:mm:ss.S').format(DateTime.now()),
        profileImg: widget.chatInfo.profileImg);

    if (chatData.message != null) {
      webSocketClient.onSend(chatData); // web socket 으로 데이터 전송
    }
  }
}
