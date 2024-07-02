import 'package:flutter/material.dart';
import 'package:sympathy_app/utils/constants.dart';

class LoginEdit{
  TextEditingController idController   = TextEditingController();
  TextEditingController passController = TextEditingController();

  Map<String, dynamic> toMap(String tokenFcm) {
    Map<String, dynamic> toMap = {
      'userID'   : idController.text,
      'password' : passController.text,
      'fcmToken' : tokenFcm,
    };
    return toMap;
  }

}

class SignEdit{

  TextEditingController idController          = TextEditingController(); // 아이디
  TextEditingController passController        = TextEditingController(); // 비밀번호
  TextEditingController pass2Controller       = TextEditingController(); // 비밀번호 확인
  TextEditingController nameController        = TextEditingController(); // 이름
  TextEditingController jobController         = TextEditingController(); // 회사명 -> 직업명
  TextEditingController emailController       = TextEditingController(); // 이메일
  TextEditingController codeController        = TextEditingController(); // 인증 코드


  Map<String, dynamic> toMap(String gender, String base64, String dateOfBirth) {
    Map<String, dynamic> toMap = {
      'userID'      : idController.text,
      'accountType' : 'N',
      'password'    : passController.text,
      'name'        : nameController.text,
      'gender'      : gender,
      'companyName' : jobController.text,  // 회사명 -> 직업명
      'dateOfBirth' : dateOfBirth,
      'authority'   : 'ROLE_USER',
      'profileImg'  : base64Head + base64,
      'phone'       : emailController.text

      /// emailController로 받고 phone으로 넘기

    };

    return toMap;
  }
}


class PasswordEdit{

  TextEditingController idController          = TextEditingController(); // 아이디
  TextEditingController beforePassController  = TextEditingController(); // 기존 비밀번호
  TextEditingController newPassController     = TextEditingController(); // 새 비밀번호
  TextEditingController newPass2Controller    = TextEditingController(); // 새 비밀번호 확인

  Map<String, dynamic> toMap() {
    Map<String, dynamic> toMap =
    {
      'userID'      : idController.text,
      'password'    : newPass2Controller.text,
    };

    return toMap;
  }
}