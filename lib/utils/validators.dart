
import 'package:flutter/material.dart';

import 'etc.dart';
import 'dio_client.dart';

class CheckValidate{
  bool validateUserID( String value, BuildContext context){
    if(value.isEmpty)
    {
      Etc.newShowSnackBar('아이디가 비어 있습니다.', context);
      return true;
    }
    else if(value.length<5)
    {
      Etc.newShowSnackBar('아이디 길이 5이상 작성바랍니다.', context);
      return true;
    }
    else
    {
      return false;
    }
  }

  Future<bool> validateEmail( String value, BuildContext context) async {
    if(value.isEmpty)
    {
      Etc.dialog('이메일 확인', '이메일 작성란이 비어 있습니다.', context);
      return false;
    }
    else {
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);
      if(!regExp.hasMatch(value))
      {
        Etc.dialog('이메일 확인', '잘못된 이메일 형식입니다.', context);
        return false;
      }else{

        Map<String,dynamic>toMap = {'email': value};

        String meg = await client.checkEmail(toMap);
        if(meg == 'Success')
        {
          Etc.dialog('이메일 확인', '사용하실 수 없는 이메일 입니다.', context);
          return false;
        }
        else
        {
          Etc.dialog('이메일 확인', '사용가능한 이메일 입니다.', context);
          return true;
        }
        return true;
      }
    }
  }

  bool validatePassword(String value, BuildContext context){
    if(value.isEmpty)
    {
      Etc.newShowSnackBar('비밀번호를 입력하세요.', context);
      return true;
    }else
      {
        print('value.length :'+value.length.toString());
          if(value.length<8)
          {
            Etc.newShowSnackBar('비밀번호 8자 이상 입력 바랍니다.', context);
            return true;
          }else{
            return false;
          }
      }
  }
}