import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sympathy_app/data/coach.dart';

import 'constants.dart';

class Etc{

  static showQuestion(BuildContext context){
   return showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline_sharp, color: mainColor),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('문의', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('hunkim@keapa.co.kr 문의 바랍니다.', textScaleFactor: 0.85, softWrap: true,),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>[
              TextButton(
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  static newShowSnackBar(String meg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(meg, textScaleFactor: 0.9,),backgroundColor: mainColor,));
    }

  static imageCircle(UserListData userListData){
    final String imagePath = 'images/man_d.png';
    final String baseProfileUrl = 'http://106.251.70.71:50006/profile/';

    return userListData.profileImg == '-' ?
    SizedBox(width: 65.0, height: 65.0, child: Image.asset(imagePath, fit: BoxFit.cover)):
      CircleAvatar(
        radius: 10.0,
        backgroundImage: NetworkImage(baseProfileUrl + userListData.userID +'/'+userListData.profileImg),
        backgroundColor: Colors.transparent,
      );
  }

  static settingImageCircle(UserDetails userDetails){
    final String imagePath = 'images/man_d.png';
    final String baseProfileUrl = 'http://106.251.70.71:50006/profile/';

    return userDetails.profileImg == '-' ?
    SizedBox(width: 60.0, height: 60.0, child: Image.asset(imagePath, fit: BoxFit.fill)):
    CircleAvatar(
      radius: 45.0,
      backgroundImage: NetworkImage(baseProfileUrl + userDetails.userID +'/'+userDetails.profileImg),
      backgroundColor: Colors.transparent,
    );
  }
  static solidLine(BuildContext context){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 1.0,
        color: lineColor,
      ),
    );
  }

  static String ynConvert(String input) {
    String returnValue;

     if(input == 'Y')
       returnValue = '완료';
     else
       returnValue = '미 완료';

     return returnValue;
  }

  static String parsingEndMessage(String text){ // 채팅 종료 메시지 파싱
     String  parsingEndMessage = text.substring(5,17);
      return parsingEndMessage;
    }

  //map print
  static void getValuesFromMap(Map map) {
    // Get all values
    print('----------');
    print('Get values:');
    map.values.forEach((value) {
      print(value);
    });
  }
  static var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 1, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 200, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
    ),
  );

  static MediaQueryData getScaleFontSize(BuildContext context, {double fontSize}){
    final mqData = MediaQuery.of(context);
    return mqData.copyWith(textScaleFactor: fontSize);
  }


  static dialog(String headText, String text, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title:Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: mainColor,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(headText, textScaleFactor: 0.8, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(text, textScaleFactor: 0.85, style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>
            [
              TextButton (
                child: new Text("확인", textScaleFactor:1),
                onPressed: () async
                {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

}

