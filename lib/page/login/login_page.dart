import 'package:flutter/material.dart';
import 'package:sympathy_app/page/setting/terms_page.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/edit_controller.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/fcm_service.dart';
import 'package:sympathy_app/utils/network_check.dart';
import 'package:sympathy_app/widget/button.dart';
import '../../widget/widget.dart';

/// 로그인 화면
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _checkNetwork = CheckNetworkConnection(); // 네트워크 체크
  LoginEdit loginEdit = LoginEdit();
  String tokenFcm;

  @override
  void initState() {
    super.initState();

    //네트워크 체크
    _checkNetwork.checkNetWork(context);

    // FCM 가져오기
    FCMService(true).getToken().then((token) {
      tokenFcm = token;
      print('>>>> tokenFcm :'+ tokenFcm.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },

          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  Container(height: 300, width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: mainColor,
                        borderRadius: new BorderRadius.only( bottomLeft: const Radius.circular(30.0), bottomRight: const Radius.circular(30.0)) ),
                    child: Center(
                        child: Padding(padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
                            child: Image.asset('images/bi.png', height: 160, width: 160)))),

                Column(
                  children:
                  [
                    Padding(padding: const EdgeInsets.fromLTRB(40, 50, 40, 0),
                      child: LoginInputEdit(iconData: Icons.account_box, hint: '아이디를 입력해주세요', controller: loginEdit.idController, type: 'id'),),

                    Padding(padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                      child: LoginInputEdit(iconData: Icons.vpn_key, hint: '비밀번호를 입력해주세요', controller: loginEdit.passController, type: 'pass'),),

                    LoginButton(loginEdit: loginEdit, context:context, tokenFcm:tokenFcm,),

                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>
                      [
                        Container(
                            child: InkWell(
                                onTap: () =>
                                {
                                 Etc.showQuestion(context)
                                },
                                child: Padding(padding: const EdgeInsets.all(20.0),
                                    child: Text('문의 하기', textScaleFactor:0.9,style: TextStyle(color: Colors.grey))))),

                        Container(
                          child: InkWell(
                              onTap: () =>
                              {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TermsPage(callback: ()=> resultSign())))
                              },
                              child: Padding(padding: const EdgeInsets.all(20.0),
                                child: Text('회원가입', textScaleFactor:0.9,style: TextStyle(color: Colors.grey)))))
                      ],
                    ),
                  ],
                )
            ]),
          ),
        ));
  }

  // 회원가입 완료 메시지
  resultSign(){
    Etc.newShowSnackBar('회원가입 완료', context);
  }
}
