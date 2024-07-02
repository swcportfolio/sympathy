
import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/hope_time.dart';
import 'package:sympathy_app/data/satisfaction.dart';
import 'package:sympathy_app/data/survey.dart';
import 'package:sympathy_app/page/chat/chat_list_page_bar.dart';
import 'package:sympathy_app/page/chat/chat_page.dart';
import 'package:sympathy_app/page/setting/hope_time.dart';
import 'package:sympathy_app/page/login/login_page.dart';
import 'package:sympathy_app/page/login/signup_page.dart';
import 'package:sympathy_app/page/setting/hope_time_change_page.dart';

import 'package:sympathy_app/page/setting/password_change_page.dart';
import 'package:sympathy_app/utils/auto_login.dart';
import 'package:sympathy_app/utils/common.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/data/login.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/edit_controller.dart';
import 'package:sympathy_app/utils/fcm_service.dart';
import 'package:sympathy_app/utils/reservation_notification.dart';
import 'package:sympathy_app/utils/save_data.dart';
import 'package:sympathy_app/utils/validators.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';

/// 로그인 버튼
// ignore: must_be_immutable
class LoginButton extends StatelessWidget {
  final LoginEdit loginEdit;
  final BuildContext context;
  final String tokenFcm;


  LoginButton({this.loginEdit, this.context, this.tokenFcm});

  AutoLogin autoLogin = AutoLogin();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            elevation: 5.0,
            backgroundColor: mainColor,
            padding: EdgeInsets.all(17.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0))),
            onPressed: ()
            {
             _checkLogin(context);
            },
            child: Text('로그인',textScaleFactor: 1.1, style: TextStyle(color: Colors.white))
        )
    );
  }

  void _checkLogin(BuildContext context) async {
    if (loginEdit.idController.text.isEmpty || loginEdit.passController.text.isEmpty) {
      Etc.newShowSnackBar('아이디 또는 패스워드를 입력하시오', context);
    } else {
      try {
        print('fcm token ::'+tokenFcm);
        LoginData loginData = await client.dioLogin(loginEdit.toMap(tokenFcm));


        if (loginData.token != null)
          autoLogin.authLogin(loginEdit.idController.text, loginEdit.passController.text, loginData, context);
         else
           Etc.newShowSnackBar('아이디 또는 비밀번호를 확인하세요.', context);


      } catch (e) {
        Etc.newShowSnackBar(e.toString().replaceFirst('Exception: ', ''), context);
      }
    }
  }
}

///회원가입 버튼
class SignButton extends StatelessWidget {
  final String text;
  final SignEdit editSignCnt;
  final String gender;
  final String base64Str;          // 갤러리에서 가져온 이미지
  final String defaultImage64Str;  // 기본이미지
  final BuildContext context;
  final VoidCallback callback;
  final String dateOfBirth;
  final bool isPossibleEmail;
  // final bool codeVerification;
  // final String selectedCompanyName;
  
  SignButton({ this.text, this.editSignCnt, this.context, this.gender, this.base64Str, this.defaultImage64Str,
    this.callback, this.dateOfBirth, this.isPossibleEmail});

  final  checkValidate = CheckValidate();

  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: EdgeInsets.only(top: 0.0, right: 30.0, left: 30.0, bottom: 10.0),
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            elevation: 5.0,
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            backgroundColor: mainColor,
          ),
            onPressed: ()
            {
              if(text == '회원 가입')
                _checkSign(context);
              else
                Navigator.pop(context);
            },
            child: Text(text, textScaleFactor: 1.1, style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold))));
  }

  void _checkSign(BuildContext context) async{
    String base64;
    print('----> button : '+isPossibleEmail.toString());
    if(isPossibleEmail){
      if(checkValidate.validateUserID(editSignCnt.idController.text, context)){
      }else if(checkValidate.validatePassword(editSignCnt.passController.text, context)){
      }else if(editSignCnt.passController.text != editSignCnt.pass2Controller.text){
        Etc.newShowSnackBar('비밀번호가 일치 하지 않습니다.', context);
      }else if(editSignCnt.nameController.text.isEmpty ){
        Etc.newShowSnackBar('이름을 작성해주세요.', context);
      }else if(editSignCnt.jobController.text.isEmpty ){
        Etc.newShowSnackBar('직업 명을 작성해주세요.', context);
      }else if(gender == '') {
        Etc.newShowSnackBar('성별을 선택해주세요.', context);
      } else{
        if(base64Str == null)
        {
          base64 = defaultImage64Str;
        }
        else{
          base64 = base64Str;
        }

        // 서버로 회원가입
        String mes =  await client.dioSign(editSignCnt.toMap(gender, base64, dateOfBirth));
        if(mes == 'Success')
        {
          callback();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=> LoginPage()));
        }
        else if(mes == '중복된 아이디입니다.')
        {
          Etc.newShowSnackBar('중복된 아이디입니다.', context);
        }
      }
    }else
      Etc.dialog('이메일 확인', '이메일 중복 확인 해주세요.', context);
  }
}

// ignore: must_be_immutable
class ChattingButton extends StatelessWidget {

  final String text;
  final UserListData userListData;  // [pys 추가]
  final Authorization auth;
  final bool identification;
  final VoidCallback callback;
  final WebSocketClient webSocketClient;
  final String senderName;
  ChattingButton({ this.text, this.auth, this.userListData, this.identification, this.callback, this.webSocketClient, this.senderName });

  @override
  Widget build(BuildContext context) {
    return Container(
        width : MediaQuery.of(context).size.width,
        height: 50,
        child: TextButton(
          style: TextButton.styleFrom(
            elevation: 3.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
            backgroundColor: mainColor,
          ),
          onPressed: ()
          {
              if(identification)// 나의 내담자 - 채팅하기
              {
                if(userListData.userID == null){// 코치 아이디, 유저 아이디, 유저 아이디 유저 name
                  print('_profile.userID');
                }else{
                  print('senderID:' +auth.userID+ 'receiverID:' +userListData.userID+ 'peerID:' +userListData.userID +'peerName:'+ userListData.name);
                }
                ChatData chatInfo = ChatData(
                    senderID: auth.userID,
                    receiverID: userListData.userID,
                    peerID: userListData.userID,
                    senderName: senderName,
                    peerName: userListData.name,
                    profileImg: userListData.profileImg,
                    groupID: Common.getGroupID(auth.userID, userListData.userID));
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChatPage(chatInfo, auth)));

              }
              else{
                print(' 나의 내담자 리스트 등록 버튼'+identification.toString());
                commitDialog('내담자 등록', context);
              }
          },
          child: Text(identification? text:'내담자 등록', textScaleFactor: 1.1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),)
    );
  }

  //내담자 등록 dialog
  commitDialog(String title ,BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.check_circle_outline,color: mainColor),

                Padding(
                  padding: const EdgeInsets.only(left: 5, top:2),
                  child: Text('등록', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            // Padding(padding: const EdgeInsets.only(left: 10, top:10),
            //                   child:
            //                 ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("$title하시겠습니까?", textScaleFactor: 0.85),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),

            actions: <Widget>[
              TextButton(child: new Text("취소", textScaleFactor: 1.0),
                onPressed: () {  Navigator.pop(context);  },
              ),
              TextButton(
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: () async{

                  Map<String, dynamic> toMap = {
                    'userID': userListData.userID, // 선택한 내담자 userID
                    'requesterID' : auth.userID,   // 상담사 ID
                  };

                  String success = await client.commitRequest(toMap);
                  if(success == 'Success') {
                    Navigator.pop(context);
                    callback();
                    print('내담자 신청 완료');
                  }
                  else {
                    Etc.newShowSnackBar(success, context);
                  }
                },
              ),
            ],
          );
        });
  }

}

///로그아웃 버튼
class LogoutButton extends StatelessWidget {
  final String text;
  final BuildContext mainContext;

  WebSocketClient webSocketClient;

  LogoutButton(this.text, this.mainContext, this.webSocketClient);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => logoutDialog(text, mainContext),
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: 0.0, right: 18.0, left: 18.0, bottom: 10.0),
            decoration: BoxDecoration(
                color: mainColor, borderRadius: BorderRadius.circular(5.0)),
            child: Text(text,
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold))));
  }

  logoutDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Text("$title 하시겠습니까?", textScaleFactor: 0.7),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child:  Text("취소"),
                onPressed: () {  Navigator.pop(context); },
              ),
              TextButton (
                child: new Text("확인"),
                onPressed: () {
                  webSocketClient.onEnd();
                  FCMService(false);
                 // webSocketClient.onClose();
                  deleteSaveData();

                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (route) => false);

                },
              ),
            ],
          );
        });
  }

  ///앱 SharedPreferences data 삭제
  void deleteSaveData() {
    SaveData _saveData = SaveData();
    _saveData.remove('userID');
    _saveData.remove('password');
    _saveData.remove('account');
    _saveData.remove('profileImg');
    _saveData.remove('testYN');
    _saveData.remove('hopeTimeYN');
    _saveData.remove('satisfaction');
  }
}

///설문조사 완료 버튼
// ignore: must_be_immutable
class SurveyButton extends StatelessWidget {
  final String btnName;
  final List<String> answer;
  final BuildContext context;
  final Authorization auth;


  bool isSurvey = true;
  SurveyButton({ this.btnName, this.answer, this.context, this.auth});

  final _question = Question();
  SaveData _saveData = SaveData();

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.only(top: 0.0, right: 30.0, left: 30.0, bottom: 15.0),
        width: double.infinity,
        height: 80,
        child: Padding(padding: EdgeInsets.all(10.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                  primary: mainColor),
              onPressed: () async{
                for(int i = 0 ; i<answer.length ;i++)
                  print('answer  /'+i.toString()+'/'+answer[i].toString());

                for(int i=0 ; i<answer.length ; i++){
                  if(answer[i] == '-1')
                  {
                    Etc.newShowSnackBar((i).toString()+'번째 문항 응답바랍니다.',context);
                    isSurvey = false;
                    break;
                  }
                  else if(answer[i] == '-2')
                    print('----> answer 제외');
                }

                if(isSurvey){
                  String meg = await client.dioSurvey(_question.toMap(auth.userID, answer));

                     if(meg == 'Success'){
                       Etc.newShowSnackBar( '설문조사가 완료되었습니다.', context );

                       _saveData.setStringData('testYN' , 'Y');
                       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => HopeTime(auth:auth)),(route)=>false); // 채팅화면
                     }
                }

              },
              child: Text(btnName, textScaleFactor: 1.1,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ));
  }
}

/// 이용약관 완료 버튼
class TermsButton extends StatelessWidget {
  final String btnName;
  final BuildContext context;
  final List<bool> agree;
  final VoidCallback callback;

  bool isAgree = true;
  TermsButton({ this.btnName, this.context, this.agree, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 60,
        child: Padding(padding: EdgeInsets.all(4.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
                  primary: mainColor),
              onPressed: ()
              {
                if(agree[1] == false || agree[2] == false)
                {
                  Etc.newShowSnackBar('모두 동의 바랍니다.', context);
                }else{
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SignUpPage(callback: ()=> callback())));
                }
              },
              child: Text(btnName, textScaleFactor: 1.1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ));
  }
}

///상담희망시간 완료버튼
// ignore: must_be_immutable
class HopeTimeButton extends StatelessWidget {

  final String btnName;
  final List<String> answer;
  final BuildContext context;
  final Authorization auth;
  final SetHopeTime setHopeTime;
  // final TimeNotification time1;
  // final TimeNotification time2;
  // final TimeNotification time3;
  final String division;
  final VoidCallback callback;
  HopeTimeButton({ this.btnName, this.answer, this.context, this.auth, this.setHopeTime, this.callback, this.division});

  String hopeTime1,hopeTime2,hopeTime3;
  SaveData _saveData = SaveData();
  //NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.only(top: 0, right: 0.0, left: 0.0, bottom: 10.0),
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)), primary: mainColor),
            onPressed: () async
            {
              if(setHopeTime.dateTime1 == '날짜 설정' || setHopeTime.hourTime1 =='시간 설정')
                Etc.newShowSnackBar('1순위 상담시간을 설정해 주세요.', context);

              else if( checkEmptyTime() )
              {
                timeParing();

                String msg = await client.hopeTimeUpdate(toMap());
                 if(msg =='Success')
                 {
                   // _settingTime();  상담 30분전 알림기능
                    if(division == 'setting')
                    {
                      callback();
                      Navigator.pop(context);
                    }
                    else{
                      _saveData.setStringData('hopeTimeYN'  , 'Y');
                      Etc.newShowSnackBar('상담시간 설정이 완료되었습니다.', context);
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => ChatListPageBar(auth, true)),(route)=>false); // 채팅화면
                    }

                 }
                 else if(msg == 'ERR_MS_6002'){
                   Etc.newShowSnackBar('상담사가 지정되어 변경할 수 없습니다.', context);
                 }else
                   Etc.newShowSnackBar('상담시간 설정이 실패 했습니다. 다시 시도 바랍니다.', context);

              }
              else print('시간설정 필요');
            },
            child: Text(btnName, textScaleFactor: 1.1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Map<String, dynamic> toMap()
  {
    Map<String, dynamic> toMap =
    {
      'userID'    : auth.userID,
      'hopeTime1' : hopeTime1,
      'hopeTime2' : hopeTime2,
      'hopeTime3' : hopeTime3,
    };
    return toMap;
  }
  // 시간 String 파싱
  void timeParing() {
    hopeTime1 = setHopeTime.dateTime1+' '+setHopeTime.hourTime1.replaceFirst('시', '');
    if(setHopeTime.dateTime2 != '날짜 설정')
      hopeTime2 = setHopeTime.dateTime2+' '+setHopeTime.hourTime2.replaceFirst('시', '');
    if(setHopeTime.dateTime3 != '날짜 설정')
      hopeTime3 = setHopeTime.dateTime3+' '+setHopeTime.hourTime3.replaceFirst('시', '');
  }

  // 날짜는 선택하고 시간설정 안했을 경우 예외 처리
  bool checkEmptyTime() {
    if(setHopeTime.dateTime2 != '날짜 설정' && setHopeTime.hourTime2 =='시간 설정')
    {
      Etc.newShowSnackBar('2순위 시간 설정해 주세요.', context);
      return false;
    }

    if(setHopeTime.dateTime3 != '날짜 설정' && setHopeTime.hourTime3 =='시간 설정')
    {
      Etc.newShowSnackBar('3순위 시간 설정해 주세요.', context);
      return false;
    }

    return true;
  }

  // 상담 알림 30분전 알림 셋팅
  // void _settingTime() {
  //     if(time1.hour != null) notificationService.noShowNotification1(time1);
  //     if(time2.hour != null) notificationService.noShowNotification2(time2);
  //     if(time3.hour != null) notificationService.noShowNotification3(time3);
  //   }
  }

 // 회원 탈퇴 버튼
class UserDeleteButton extends StatelessWidget {
  final String text;
  final BuildContext mainContext;
  final Authorization auth;
  UserDeleteButton(this.text, this.mainContext, this.auth);

  @override
  Widget build(BuildContext context) {

    return  Container(
        padding: EdgeInsets.only(top: 0.0, right: 18, left: 18.0, bottom: 10.0),
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            backgroundColor: mainColor,
            elevation: 5.0,
          ),
            onPressed: () {  deleteDialog(text, mainContext); },
            child: Text(text, style: TextStyle( color: Colors.white, letterSpacing: 1.5, fontSize: 15.0, fontWeight: FontWeight.bold))));
  }
  deleteDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Padding(padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: Text("$title 하시겠습니까?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),

               Padding(
                 padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                 child: Text("경고! 탈퇴 후 모든 데이터가 삭제됩니다.", style: TextStyle(fontSize: 12, color: Colors.red)),
               ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: new Text("취소"),
                onPressed: () {  Navigator.pop(context); },
              ),
              TextButton(
                child: new Text("확인"),
                onPressed: () async{

                  Map<String, dynamic> toMap(String userID){
                    Map<String, dynamic> toMap ={
                      'userID': userID,
                    };
                    return toMap;
                  }

                  String success = await client.deleteUser(toMap(auth.userID));
                   if(success =='Success') {
                     FCMService(false);

                     deleteSaveData();

                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                         builder: (BuildContext context) => LoginPage()), (route) => false);
                   }
                },
              ),
            ],
          );
        });
  }

  ///앱 SharedPreferences data 삭제
  void deleteSaveData() {
    SaveData _saveData = SaveData();
    _saveData.remove('userID');
    _saveData.remove('password');
    _saveData.remove('account');
    _saveData.remove('profileImg');
    _saveData.remove('testYN');
    _saveData.remove('hopeTimeYN');
  }
}


// 회원 탈퇴 버튼
class EndChatButton extends StatelessWidget {
  final BuildContext context;
  final Authorization auth;

  EndChatButton({ this.context, this.auth });

  @override
  Widget build(BuildContext context) {

    return  Container(
        padding: EdgeInsets.only(top: 0.0, right: 40.0, left: 40.0, bottom: 10.0),
        width: double.infinity,
        child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              backgroundColor: mainColor,
              elevation: 5.0,
            ),
            onPressed: () {  deleteDialog('상담 종료 ', context); },
            child: Text('상담 만족도 검사 진행 하기', textScaleFactor: 1.1,style: TextStyle( color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold))));
  }
  deleteDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: Text("$title하시겠습니까?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Text("경고! 종료 후 상담내역이 삭제됩니다.", style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
            actions: <Widget>[

              TextButton(
                child: new Text("취소"),
                onPressed: () {  Navigator.pop(context); },
              ),

              TextButton(
                child: new Text("확인"),
                onPressed: () async{

                  }
              ),

            ],
          );
        });
  }

}

///설문조사 완료 버튼
// ignore: must_be_immutable
class SatisfactionButton extends StatelessWidget {

  final String btnName;
  final List<String> answer;
  final List<String> resilienceAnswer;
  final BuildContext context;
  final Authorization auth;
  final VoidCallback callback;
  final String requesterID;

  String _endMessage = '수고하셨습니다.\n모든 채팅상담 과정이 종료되었습니다. 기프티콘은 입력하신 이메일로 2주내 발송될 예정입니다.';

  SatisfactionButton({ this.btnName, this.answer, this.resilienceAnswer, this.context, this.auth, this.callback, this.requesterID});

  final _question = Satisfaction();
  SaveData _saveData = SaveData();
  bool isSurvey = true;

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.only(top: 0.0, right: 0.0, left: 0.0, bottom: 10.0),
        width: double.infinity,
        height: 85,
        child: Padding(padding: EdgeInsets.all(15.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                  primary: mainColor),
              onPressed: () async{

                // for(int i=0 ; i<resilienceAnswer.length ;i++){
                //   print('리질리언스 문항/'+i.toString()+'/ :'+resilienceAnswer[i]);
                // }
                // for(int i=0 ; i<answer.length ;i++){
                //   print('만족도 문항/'+i.toString()+'/ :'+answer[i]);
                // }

                for(int i=0 ; i<resilienceAnswer.length ; i++){
                  if(resilienceAnswer[i] == '-1')
                  {
                    Etc.newShowSnackBar('리질리언스 문항 ' +(i+1).toString()+'번째 문항 응답바랍니다.',context );
                    isSurvey = false;
                    break;
                  }
                }

                for(int i=0 ; i<answer.length ; i++){
                  if(answer[i] == '-1')
                  {
                    Etc.newShowSnackBar('만족도 문항 ' +(i+1).toString()+'번째 문항 응답바랍니다.',context );
                    isSurvey = false;
                    break;
                  }
                }

                if(isSurvey)
                {
                  String meg = await client.dioSatisfaction(_question.toMap(auth.userID, requesterID, answer, resilienceAnswer));

                  if(meg == 'Success'){
                    endDialog('검사 종료', context);
                  }
                }
              },
              child: Text(btnName, textScaleFactor:1.1,style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold))),
        ));
  }
  endDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_late_outlined,color: mainColor),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(title, textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width: 240,
                      child: Text(_endMessage, textScaleFactor: 0.85, style: TextStyle(height:1.4), softWrap: true)),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>[
              TextButton (
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: ()
                {
                  Navigator.pop(context);
                  callback();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}

///패스워드 변경 버튼
class PassChangeButton extends StatelessWidget {
  final Authorization auth;
  final btnName;
  final PasswordEdit passwordEdit;
  final BuildContext context;
  final WebSocketClient webSocketClient;
  PassChangeButton(this.auth, this.btnName, this.passwordEdit, this.context, this.webSocketClient);

  final _checkValidate = CheckValidate();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                primary: mainColor
            ),
            onPressed: ()
            {
                _checkInputValue();
            },
            child: Text(btnName, textScaleFactor:1.1, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))));
  }

  void _checkInputValue() {
    if(auth.userID != passwordEdit.idController.text){
      Etc.newShowSnackBar('아이디가 일치하지 않습니다.', context);
    }else if(auth.password != passwordEdit.beforePassController.text){
      Etc.newShowSnackBar('기존 비밀번호가 틀립니다.', context);
    }else if(passwordEdit.newPassController.text != passwordEdit.newPass2Controller.text) {
      Etc.newShowSnackBar('새 비밀번호가 다릅니다. 재입력 바랍니다.', context);
    }else if(_checkValidate.validatePassword(passwordEdit.beforePassController.text, context) ||
        _checkValidate.validatePassword(passwordEdit.newPassController.text, context)){
    } else{
      logoutDialog('비밀번호 변경', context);
    }
  }

  logoutDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title:Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline,color: mainColor,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('비밀번호 변경', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('비밀번호 변경 시 재로그인이 필요합니다', textScaleFactor: 0.8, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>
              [
                TextButton(
                  child: new Text("취소", textScaleFactor:1),
                  onPressed: () {  Navigator.pop(context); },
                ),

                TextButton (
                  child: new Text("확인", textScaleFactor:1),
                  onPressed: () async {

                    String meg = await client.passUpdateDio(passwordEdit.toMap());
                      if(meg == 'Success')
                      {
                        deleteSaveData();
                        FCMService(false);
                        webSocketClient.onEnd();

                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (route) => false);
                      }
                },
              ),
            ],
          );
        });
  }
  ///앱 SharedPreferences data 삭제
  void deleteSaveData() {
    SaveData _saveData = SaveData();
    _saveData.remove('userID');
    _saveData.remove('password');
    _saveData.remove('account');
    _saveData.remove('profileImg');
    _saveData.remove('testYN');
    _saveData.remove('hopeTimeYN');
    _saveData.remove('satisfaction');
  }
}

// 회원 탈퇴 버튼
class MovePassPageButton extends StatelessWidget {

  final String btnName;
  final Authorization auth;
  final WebSocketClient webSocketClient;
  MovePassPageButton({this.btnName, this.auth, this.webSocketClient});

  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: EdgeInsets.only(top: 0.0, right: 18.0, left: 18.0, bottom: 10.0),
        width: double.infinity,
        child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              backgroundColor: mainColor,
              elevation: 5.0,
            ),
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PassChangePage(auth:auth, webSocketClient: webSocketClient)));  },
            child: Text(btnName, style: TextStyle( color: Colors.white, letterSpacing: 1.5, fontSize: 15.0, fontWeight: FontWeight.bold))));
  }
}

// ignore: must_be_immutable
class ExcludingMembersButton extends StatelessWidget {

  final String text;
  final Authorization auth;
  final UserListData userListData;
  final VoidCallback callback; // 내담자 취소 콜백

  ExcludingMembersButton(this.text, this.auth, this.userListData, this.callback);

  @override
  Widget build(BuildContext context) {
    return Container(
        width : MediaQuery.of(context).size.width,
        height: 50,
        child: TextButton(
          style: TextButton.styleFrom(elevation: 5.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),backgroundColor: mainColor),
          onPressed: ()
          {
            cancelDialog('내담자 취소' ,context);
          },
          child: Text(text, textScaleFactor:1.1 ,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
    );
  }
  // 내담자 취소
  cancelDialog(String title ,BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,color: Colors.red),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text('취소', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            // Padding(padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            //                   child: Text("$title하시겠습니까?",textScaleFactor: 0.8),
            //                 ),
            //                 Padding(
            //                   padding: const EdgeInsets.fromLTRB(18, 8, 8, 0),
            //                   child: Text('주의! 나의 내담자에서 제외됩니다.',textScaleFactor: 0.6, style: TextStyle(color: Colors.red)),
            //                 ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 13, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('$title하시겠습니까?', textScaleFactor: 0.85),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),

            actions: <Widget>[
              TextButton(child: new Text("취소", textScaleFactor: 1.0,),
                onPressed: () {  Navigator.pop(context);  },
              ),
              TextButton(
                child: new Text("확인",textScaleFactor: 1.0),
                onPressed: () async{

                  Map<String, dynamic> toMap =
                  {
                    'userID': userListData.userID, // 선택한 내담자 userID
                    'requesterID' : auth.userID,   // 상담사 ID
                  };

                  String success = await client.commitRequestCancel(toMap);
                  if(success == 'Success')
                  {
                    Navigator.pop(context);
                    callback();
                    print('====> 내담자 취소 완료');
                  }
                  else {
                    Etc.newShowSnackBar(success, context);
                  }
                },
              ),
            ],
          );
        });
  }

}

class SettingsHelpButton extends StatelessWidget {

  final String btnName;
  final Authorization auth;
  final BuildContext context;
  final WebSocketClient webSocketClient;
  final VoidCallback callback;
  SettingsHelpButton({ this.btnName, this.auth, this.context, this.webSocketClient, this.callback });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>
      {
        if(btnName == '회원 탈퇴')
          {
            if(auth.account != 'C') // 상담사는 탈퇴할 수 없다.
              deleteDialog(btnName, context)
          }
        else if(btnName == '로그아웃')
          {
            logoutDialog(btnName, context)
          }
        else if(btnName == '상담시간 변경')
          {
            if(auth.account != 'C')
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HopeTimeChangePage(auth, ()=>callback())))
          }
        else
          {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PassChangePage(auth:auth, webSocketClient: webSocketClient)))
          }
      },
      child: Padding(padding: const EdgeInsets.all(5.0),
        child: Text(btnName,textScaleFactor: 0.9),
      ),
    );
  }

  //회원 탈퇴
  deleteDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_late_outlined, color: Colors.red,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('탈퇴', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
              content:Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('$title 하시겠습니까? (데이터 삭제)', textScaleFactor: 0.85),
                  ],
                ),
              ),
              contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>
            [
              TextButton(
                child: new Text("취소", textScaleFactor: 1.0),
                onPressed: () {  Navigator.pop(context); },),
              TextButton(
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: () async
                {

                  Map<String, dynamic> toMap(String userID){
                    Map<String, dynamic> toMap ={
                      'userID': userID,
                    };
                    return toMap;
                  }

                  String success = await client.deleteUser(toMap(auth.userID));
                  if(success =='Success')
                  {
                    FCMService(false);
                    deleteSaveData();

                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()), (route) => false);
                  }
                })
            ]);
    });
  }

  //로그아웃 dialog
  logoutDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_late_outlined,color: Colors.red),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('로그아웃', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('$title 하시겠습니까?', textScaleFactor: 0.85),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>[
              TextButton(
                child: new Text("취소", textScaleFactor: 1.0),
                onPressed: () {  Navigator.pop(context); },
              ),
              TextButton (
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: ()
                {
                  webSocketClient.onEnd();
                  FCMService(false);
                  deleteSaveData();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (route) => false);
                },
              ),
            ],
          );
        });
  }

  //앱 SharedPreferences data 삭제
  void deleteSaveData() {
    SaveData _saveData = SaveData();
    _saveData.remove('userID');
    _saveData.remove('password');
    _saveData.remove('account');
    _saveData.remove('profileImg');
    _saveData.remove('testYN');
    _saveData.remove('hopeTimeYN');
  }
}
