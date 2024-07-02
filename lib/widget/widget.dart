import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/page/chat/member_profile.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';

// ignore: must_be_immutable
class LoginInputEdit extends StatelessWidget {

  final IconData iconData;
  final String hint;
  final String type;
  TextEditingController controller;
  LoginInputEdit({this.iconData, this.hint, this.controller,this.type});

  @override
  Widget build(BuildContext context) {

    return Container(
        alignment: Alignment.centerLeft,
        height: 60.0,
        child: MediaQuery(
          data: Etc.getScaleFontSize(context, fontSize: 0.75),
          child: TextField(
            autofocus: false,
            obscureText:type == 'pass'? true : false,
            controller: controller,
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                fillColor: mainColor,
                border: new OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(1.0)),
                    borderSide: BorderSide(color: Colors.red)),
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(iconData, color: mainColor),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey)
            ),
          ),
        )
    );
  }
}

// ignore: must_be_immutable
class SignInputEdit extends StatelessWidget {

  final IconData iconData;
  final String hint;
  final String type;
  final String headText;
  final FocusNode focusNode;

  TextEditingController controller = TextEditingController();

  SignInputEdit({this.iconData, this.hint, this.controller, this.type, this.headText , this.focusNode});
  var maskFormatter = new MaskTextInputFormatter(mask: '###-####-####', filter: { "#": RegExp(r'[0-9]') });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: 
      [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(headText, textScaleFactor: 0.94, style: TextStyle( fontWeight: FontWeight.bold)),
        ),
        Container(
            height: 60.0,
            alignment: Alignment.centerLeft,
            child: MediaQuery(
              data:Etc.getScaleFontSize(context, fontSize: 0.75),
              child: TextField(
                focusNode: focusNode,
                inputFormatters: type =='phone'?[maskFormatter]:[],
                autofocus: false,
                obscureText:type == 'pass'? true : false,
                controller: controller,
                keyboardType:type =='code'? TextInputType.number:TextInputType.text,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(border: new OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(5.0))),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    fillColor: Colors.red,
                    hoverColor: mainColor,
                    prefixIcon: Icon(iconData, color: mainColor),
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey)
                ),
              ),
            )
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class ProfileText extends StatelessWidget {

  final IconData iconData;
  final String text,headText;

  ProfileText({this.iconData,this.headText, this.text });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 19, 0, 5),
          child: Text(headText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50.0,

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                  child: Icon(iconData, color: mainColor,),
                ),
                Text(text, style: TextStyle(color: Colors.grey, fontFamily: 'Opensans', fontSize: 12)),
              ],
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all( width: 1.0,color: Colors.grey,),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        )


      ],
    );
  }

}

///내담자 list card
class UserCardView extends StatelessWidget {

  final UserListData userListData;
  final Color listBackgroundColor;
  final Authorization auth;
  final bool identification;// 나의 내담자: true,  내담자 찾기: false
  final String senderName;

  //hopeTime 설정 되어 있는지?
  bool isHopeTime1 = false;
  bool isHopeTime2 = false;
  bool isHopeTime3 = false;

  UserCardView(this.userListData, this.listBackgroundColor, this.auth, this.identification, {this.senderName});

  @override
  Widget build(BuildContext context) {
    setHopeTime();    //hopeTime 값이 있는지 확인

    return InkWell(
      onTap: () =>
      {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MemberProfile(userListData, auth, identification, senderName:senderName)))
      },
      child: Center(
          child: Container(
              color: listBackgroundColor,
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 16, 10),
                        child: SizedBox(height: 65.0, width: 65.0,
                            child: Etc.imageCircle(userListData)
                        ),
                      ),

                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            width: 170,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(userListData.name +' (${userListData.gender})', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 10),

                                Visibility( visible:isHopeTime1, child:Text('∙ 1 순위 : ' + userListData.hopeTime1+'시', textScaleFactor: 0.8)),
                                Visibility( visible:isHopeTime1, child:SizedBox(height: 3)),
                                Visibility( visible:isHopeTime2, child:Text('∙ 2 순위 : ' + userListData.hopeTime2+'시', textScaleFactor: 0.8)),
                                Visibility( visible:isHopeTime2, child:SizedBox(height: 3)),
                                Visibility( visible:isHopeTime3, child:Text('∙ 3 순위 : ' + userListData.hopeTime3+'시', textScaleFactor: 0.8)),
                                Visibility( visible:isHopeTime3, child:SizedBox(height: 3)),
                                // Text('설문 여부 : ' + Etc.ynConvert(userListData.testYN), style: TextStyle(fontSize: 13)),
                                // SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Visibility( // 상담 D-Day
                        visible: !identification,
                        child: Expanded(
                            flex: 2,
                            child: Text(userListData.dday, textScaleFactor: 0.8, style: TextStyle(color: Colors.red))),
                      ) // 상담 D-day

                    ],
                  )
                ],
              )
          )
      ),
    );
  }

  void setHopeTime() {
    if(userListData.hopeTime1 != '-')
      isHopeTime1 = true;

    if(userListData.hopeTime2 != '-')
      isHopeTime2 = true;

    if(userListData.hopeTime3 != '-')
      isHopeTime3 = true;

  }
}

///회원가입 코드 인증 widget
class CheckCodeEdit extends StatelessWidget {

  final TextEditingController codeController;
  final TextEditingController selectedCompanyName;
  final List<String> code;
  final List<String> companyName;
  final BuildContext context;
  final VoidCallback callback;
  final FocusNode focusNode;

  CheckCodeEdit({ this.codeController, this.selectedCompanyName, this.code, this.companyName, this.context, this.callback, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,

      child: Row(
        children:
        [
          Expanded(
              child: SignInputEdit(controller: codeController  , iconData: Icons.admin_panel_settings_outlined, headText: '인증코드(회사명 입력 필수 *)', hint: '인증코드 6자리 넣어주세요', type: 'code', focusNode:focusNode)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 29,0, 0),
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      primary: mainColor),
                  onPressed: ()
                  {
                    FocusScope.of(context).unfocus();

                    if(codeController.text.isEmpty)
                    {
                      buildDialog('인증코드가 비어있습니다.', Colors.red);
                    }
                    else if(_checkCode())
                    {
                      buildDialog('인증이 완료되었습니다.',mainColor);
                      callback();
                    }
                    else
                    {
                      buildDialog('인증코드 및 회사명 확인바랍니다.',Colors.red);
                    }

                  },
                  child: Text('인증하기', textScaleFactor: 0.9, style: TextStyle(color: Colors.white, letterSpacing: 1.5))),
            ),
          )
        ],
      ),
    );
  }
  // [newDialog]
  buildDialog(String meg, Color mColor) {
    return
      showDialog(context: context, barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,color: mColor,),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text('인증', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
                content:Padding(
                  padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(meg.toString(), textScaleFactor: 0.85),
                    ],
                  ),
                ),
                contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
              actions: <Widget>[
                TextButton(
                  child: Text('확인', textScaleFactor:1.1),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
  }

  bool _checkCode() {
    print('--->  codeController.text : '+codeController.text);
    print('--->  selectedCompanyName : '+selectedCompanyName.text);
    print('---> ---------------------------------------------');

    for(int i = 0 ; i<code.length ; i++){
      print('--->  company : '+companyName[i]);
      print('--->  code : '+code[i]);


      if(codeController.text == code[i] && companyName[i] == selectedCompanyName.text){
        return true;
      }else{

      }
    }
    return false;
  }

}

// ignore: must_be_immutable
class SearchInputEdit extends StatelessWidget {

  final IconData iconData;
  final String hint;
  final String type;
  final String headText;
  final FocusNode focusNode;

  TextEditingController controller = TextEditingController();

  SearchInputEdit({this.iconData, this.hint, this.controller, this.type, this.headText , this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(headText, textScaleFactor: 0.94, style: TextStyle( fontWeight: FontWeight.bold)),
        ),

        Container(
            height: 60.0,
            alignment: Alignment.centerLeft,
            child:MediaQuery(
              data: Etc.getScaleFontSize(context,fontSize:0.96),
              child: TextField(
                autofocus: false,
                obscureText:false,
                controller: controller,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black, fontSize: 13),
                decoration: InputDecoration(border: new OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(5.0))),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    fillColor: Colors.red,
                    hoverColor: mainColor,
                    prefixIcon: Icon(iconData, color: mainColor),
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12)
                ),
              ),
            )
        )

      ],
    );
  }
}



