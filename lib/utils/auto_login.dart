import 'package:flutter/material.dart';

import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/login.dart';
import 'package:sympathy_app/page/chat/chat_list_page.dart';
import 'package:sympathy_app/page/chat/chat_list_page_bar.dart';
import 'package:sympathy_app/page/chat/main_page.dart';
import 'package:sympathy_app/page/setting/survey_page.dart';
import 'package:sympathy_app/utils/save_data.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';

class AutoLogin{
  SaveData _saveData = SaveData();

 void authLogin(String id, String password, LoginData loginData, BuildContext context) {
    Authorization auth = Authorization(
        userID    : id,
        password  : password,
        account   : loginData.accountType,
        profileImg: loginData.profileImg
    );

    // 로그인 성공으로 자동로그인을 위한 id,password 저장
    _saveData.setStringData('userID'      , id);
    _saveData.setStringData('password'    , password);
    _saveData.setStringData('account'     , loginData.accountType);
    _saveData.setStringData('profileImg'  , loginData.profileImg);
    _saveData.setStringData('testYN'      , loginData.testYN);
    _saveData.setStringData('hopeTimeYN'  , loginData.hopeTimeYN);

    if(loginData.accountType =='N'){ // 내담자일때
      if(loginData.testYN == 'N'){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => SurveyPage(auth:auth) ),(route)=>false); // 설문조사 화면
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ChatListPageBar(auth, false) )); // 채팅화면
      }
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainPage(auth, false) )); // 상담사 화면
    }

  }

}