import 'package:flutter/material.dart';

final mainColor= Color(0xFF5cc6ba);
final doUnselectedItemColor = Color(0xFF898989);
final satisfactionBackgroundColor = Color(0xFFE5E5E5);

final doSettingBackground = Color(0xffcce8e5);

final userList_1 = Color(0xffe8f5f3);
final userList_2 = Color(0xfff5fcfa);

final lineColor  = Color(0xff8f8f8f);

final genderColor  = Color(0xff49c6a0);


final String base64Head = 'data:image/png;base64,';
final String endMessage = '[end]상담이 종료되었습니다.[/end]';
final String parsingEndMessage = '상담이 종료되었습니다.';

final doBoxDecorationStyle = BoxDecoration(
    color: Colors.white, // Color(0xFF56CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
          color: Colors.black12,
          blurRadius: 6.0,
          offset: Offset(0, 2)
      )
    ]
);

//appbar
Widget doAppBar(String title){
  return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: mainColor,
      title: Text(title, textScaleFactor: 0.9, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true);
}

