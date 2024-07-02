import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sympathy_app/utils/etc.dart';

class CheckNetworkConnection{

  Future<ConnectivityResult> checkConnectionStatus() async
  {
    var result = await (Connectivity().checkConnectivity());
    return result;
  }

  void checkNetWork(BuildContext context) async {

    var result = await checkConnectionStatus();
    if (result == ConnectivityResult.mobile)
    {
      // I am connected to a mobile network. 모바일 데이터 사용
      print('====> [NetWork] : '+'mobile network');
    }
    else if (result == ConnectivityResult.wifi)
    {
      // I am connected to a wifi network. 와이파이 사용
      print('====> [NetWork] : '+'wifi network');

    }else{
      print('====> [NetWork] : '+'네트워크 연결 필요');
      Etc.newShowSnackBar('네트워크를 확인해 주세요.', context);
    }
  }
}