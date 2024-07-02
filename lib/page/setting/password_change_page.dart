import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/edit_controller.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/button.dart';
import 'package:sympathy_app/widget/widget.dart';

class PassChangePage extends StatefulWidget { /// 웹소켓, 재로그인이 필요하다. 로그아웃 기능 만들어야된다.

  final Authorization auth;
  final WebSocketClient webSocketClient;
  PassChangePage({this.auth, this.webSocketClient});

  @override
  _PassChangePageState createState() => _PassChangePageState();
}

class _PassChangePageState extends State<PassChangePage> {

  PasswordEdit _passwordEdit = PasswordEdit();
  final String title = '비밀번호 변경';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar(title),

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 1, 30, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              SizedBox(height: 20),

              SignInputEdit(controller: _passwordEdit.idController          , iconData: Icons.account_box, headText: '아이디', hint: '아이디를 입력해주세요.', type: 'id'),
              SignInputEdit(controller: _passwordEdit.beforePassController  , iconData: Icons.vpn_key, headText: '기존 비밀번호', hint: '사용중인 비밀번호를 입력해주세요.', type: 'pass'),
              SizedBox(height: 25),
              SignInputEdit(controller: _passwordEdit.newPassController     , iconData: Icons.vpn_key, headText: '새 비밀번호', hint: '비밀번호 8자 이상 입력해주세요.', type: 'pass'),
              SignInputEdit(controller: _passwordEdit.newPass2Controller    , iconData: Icons.vpn_key, headText: '새 비밀번호 확인', hint: '새 비밀번호 재입력해주세요.', type: 'pass'),

              SizedBox(height: 30),
              PassChangeButton(widget.auth, '변경 하기', _passwordEdit, this.context, widget.webSocketClient)

            ],
          ),
        ),
      )
    );
  }
}
