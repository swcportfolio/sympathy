import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/hope_time.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/lifecycle_event_handler.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/button.dart';

class SettingPage extends StatefulWidget {
  final BuildContext homeContext;
  final Authorization auth;
  final WebSocketClient webSocketClient;

  SettingPage(this.homeContext, this.auth, {this.webSocketClient});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  UserDetails userDetails;
  int pageIndex= 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar('설정'),

     body: Stack(
       children: [
         FutureBuilder(
           future: client.getUserDetails(widget.auth.userID, widget.auth.account),
           builder: (context, snapshot) {
             if (snapshot.hasError) {
               return Container(
                   child: Center(
                       child: Text(snapshot.error.toString().replaceFirst('Exception: ', ''),
                           style: TextStyle(
                               color: Colors.white, fontSize: 20.0))));
             }
             if (!snapshot.hasData) {
               return Container(
                   child: Center(
                       child: SizedBox(height: 40.0, width: 40.0,
                           child: CircularProgressIndicator(strokeWidth: 5,))));
             }
             if (snapshot.connectionState == ConnectionState.done) {
               userDetails = snapshot.data;
             }
             return profile();
           },
         ),
       ],
     )
    );
  }
  profile() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 1, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 38.5, 0, 0.5),
                    child: Etc.settingImageCircle(userDetails)
                  ),
                ],
              ),
              SizedBox(height: 15),
              Padding(padding: const EdgeInsets.fromLTRB(13, 20, 13, 20),
                child: Container(
                    height: 350,
                    width:MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(border: Border.all( width: 2.0,color: mainColor,),
                      borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    ),
                    child: Padding(padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          profileItem('아이디'   , userDetails.userID),
                          Etc.solidLine(context),
                          profileItem('이름'    , userDetails.name),
                          Etc.solidLine(context),
                          profileItem('성별'    , userDetails.gender),
                          Etc.solidLine(context),
                          profileItem('생년월일' , userDetails.dateOfBirth),
                          Etc.solidLine(context),
                          profileItem('1순위' , userDetails.hopeTime1+'시'),
                          Etc.solidLine(context),
                          profileItem('2순위' , userDetails.hopeTime2+'시'),
                          Etc.solidLine(context),
                          profileItem('3순위' , userDetails.hopeTime3+'시'),

                        ],
                      ),
                    )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  SettingsHelpButton(btnName:'로그아웃', context:context, webSocketClient:widget.webSocketClient),
                  Text('|'),
                  SettingsHelpButton(btnName:'비밀번호 변경', auth:widget.auth, webSocketClient:widget.webSocketClient),
                  Text('|'),
                  SettingsHelpButton(btnName:'상담시간 변경', context:context,auth:widget.auth,callback:()=>updateHopeTime()),
                  Text('|'),
                  SettingsHelpButton(btnName:'회원 탈퇴', context:context,auth:widget.auth),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }


  ///이름, 성별, 생년월일
  profileItem(String textTitle, String value){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children:
             [
              Image.asset('uu.png', width: 10, height: 10,),
              SizedBox(width: 10),
              Text(textTitle,textScaleFactor:0.95, style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          Text(value,textScaleFactor:0.9),
        ],
      ),
    );
  }

  updateHopeTime(){
    setState(() {
      Etc.newShowSnackBar('상담시간이 변경되었습니다.', context);
    });
  }

}
