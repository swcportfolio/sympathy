import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/hope_time.dart';
import 'package:sympathy_app/data/time.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/reservation_notification.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/button.dart';

class HopeTime extends StatefulWidget {
  final Authorization auth;

  HopeTime({this.auth});

  @override
  _HopeTimeState createState() => _HopeTimeState();
}

class _HopeTimeState extends State<HopeTime> {

  final String title = '상담시간 설정';
  int timeHour = 9;          // 시간 설정-최소 9시부터
  SetHopeTime setHopeTime ;  //hopeTime 객체 생성
  final headText  = '* 심리검사 결과는 전문상담사님과 채팅상담을 통해 확인 가능합니다. 상담 가능시간을 선택해 주세요.';

 // TimeNotification time1 = TimeNotification();
 // TimeNotification time2 = TimeNotification();
 // TimeNotification time3 = TimeNotification();

  @override
  void initState() {
    super.initState();
    NotificationService();
    setHopeTime = SetHopeTime('날짜 설정','날짜 설정','날짜 설정','시간 설정','시간 설정','시간 설정');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar(title),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(headText,textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(flex:5, child: buildTextBox('(필수 *)', Icons.calendar_today_outlined, setHopeTime.dateTime1, identifier:setHopeTime.identifier_1)),
                Expanded(flex:5, child: buildTextBoxTime(Icons.access_time_outlined, setHopeTime.hourTime1, identifier:setHopeTime.identifier_1)),
              ],
            ),
            Row(
              children: [
                Expanded(flex:5, child: buildTextBox('(선택)', Icons.calendar_today_outlined, setHopeTime.dateTime2, identifier:setHopeTime.identifier_2)),
                Expanded(flex:5, child: buildTextBoxTime(Icons.access_time_outlined, setHopeTime.hourTime2, identifier:setHopeTime.identifier_2)),
              ],
            ),
            Row(
              children: [
                Expanded(flex:5, child: buildTextBox('(선택)', Icons.calendar_today_outlined, setHopeTime.dateTime3, identifier:setHopeTime.identifier_3)),
                Expanded(flex:5, child: buildTextBoxTime(Icons.access_time_outlined, setHopeTime.hourTime3, identifier:setHopeTime.identifier_3)),
              ],
            ),
            SizedBox(height: 40),

            HopeTimeButton(btnName: '설정완료', setHopeTime:setHopeTime, auth: widget.auth, context: context,division: 'first')
          ],
        ),
      ),
    );
  }

  /// 날짜 설정
 Widget buildTextBox(String headText, IconData iconData, String hint, {int identifier}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 19, 0, 5),
          child: Text(headText == '생년월일'? headText: identifier.toString()+ '순위 '+headText,textScaleFactor: 1.0,
              style: TextStyle(color:headText =='(필수 *)'?Colors.red:Colors.black, fontWeight: FontWeight.bold)),
        ),

        MediaQuery(
         data:Etc.getScaleFontSize(context, fontSize: 0.9),
          child: InkWell(
            onTap: (){
              FocusScope.of(context).unfocus();
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:13),
                      doneStyle: TextStyle(color: Colors.black, fontSize: 13),
                      cancelStyle: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    showTitleActions: true,
                    maxTime: DateTime(2022, 5, 31),
                    minTime: DateTime.now().add(Duration(days: 3)),
                    onChanged: (date) { print('change $date'); },
                    onConfirm: (date) { print('confirm $date');

                    setState(() {

                        if(identifier == setHopeTime.identifier_1) {
                          if(exceptSunday(date)){
                            setHopeTime.dateTime1 = date.year.toString() + '-' + date.month.toString() + '-' + date.day.toString();

                            // time1.year = date.year;
                            // time1.month = date.month;
                            // time1.day   = date.day;
                            // time1.num = 1;
                          }

                        }
                        else if(identifier == setHopeTime.identifier_2){
                          if(exceptSunday(date)){
                            setHopeTime.dateTime2 = date.year.toString() +'-'+ date.month.toString() +'-'+ date.day.toString();

                            // time2.year = date.year;
                            // time2.month = date.month;
                            // time2.day   = date.day;
                            // time1.num = 2;
                          }

                        }
                        else if(identifier == setHopeTime.identifier_3){
                            if(exceptSunday(date)){
                              setHopeTime.dateTime3 = date.year.toString() +'-'+ date.month.toString() +'-'+ date.day.toString();

                              // time3.year = date.year;
                              // time3.month = date.month;
                              // time3.day   = date.day;
                              // time1.num = 3;
                            }
                          }

                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.ko);
            },
            child: Container(
              alignment: Alignment.centerLeft,
              height: 47.0,
              child: Padding(padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                      child: Icon(iconData, color: mainColor)),

                    Text(hint, textScaleFactor:0.9, style: TextStyle(color: Colors.grey)),

                  ],
                ),),
              decoration: BoxDecoration(border: Border.all( width: 1.0,color: Colors.grey,), borderRadius: BorderRadius.all(Radius.circular(1.0)),
              ),),),
        )
      ],
    );
  }

  ///시간 설정
  Widget buildTextBoxTime(IconData iconData, String hint,{int identifier}) {
    return Padding(padding: const EdgeInsets.fromLTRB(15, 40, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()
            {
              FocusScope.of(context).unfocus();
              _showIntegerDialog(identifier);
            },

            child: Container(
              alignment: Alignment.centerLeft,
              height: 47.0,
              child: Padding(padding: const EdgeInsets.all(8.0),
                child: Row(
                  children:
                  [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                      child: Icon(iconData, color: mainColor)),
                    Text(hint, textScaleFactor:0.95, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],

                ),),
              decoration: BoxDecoration(border: Border.all( width: 1.0,color: Colors.grey,), borderRadius: BorderRadius.all(Radius.circular(1.0)),
              ),),)
        ],
      ),
    );
  }

  /// 사간설정- dialog
  Future _showIntegerDialog(int identifier) async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return MediaQuery(
          data:Etc.getScaleFontSize(context, fontSize: 1.0),
          child: NumberPickerDialog.integer(selectedTextStyle: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
            minValue: 10, maxValue: 21, initialIntegerValue: 10, highlightSelectedValue:true, haptics:true,
              decoration:BoxDecoration(borderRadius: BorderRadius.circular(40)),
              title:Row(
                children:
                [
                  Image.asset('check.png',width: 15, height: 15,color: mainColor),
                  SizedBox(width: 10),
                  Text("1시간 단위(10시~21시)",textScaleFactor: 0.8),
                ],
              ),
              confirmWidget:Text('확인',textScaleFactor: 1.0, style: TextStyle(color: mainColor),),
              cancelWidget: Text('취소',textScaleFactor: 1.0, style: TextStyle(color: mainColor))),
        );
      },
    ).then((num value){
      if(value != null){
        if(value is int){
          setState(() {

            if(identifier == setHopeTime.identifier_1){
              setHopeTime.hourTime1 = value.toString()+'시';
             // time1.hour = value; // 1순위 알림 설정
            }
            else if(identifier == setHopeTime.identifier_2){
              setHopeTime.hourTime2 = value.toString()+'시';
             // time2.hour = value; // 2순위 알림 설정
            }
            else if(identifier == setHopeTime.identifier_3){
              setHopeTime.hourTime3 = value.toString()+'시';
             // time3.hour = value; // 3순위 알림 설정
            }

          });
        }
      }
    });
  }

  ///일요일 제외
  exceptSunday(var date){
    var moonLanding= DateTime(date.year,date.month,date.day);
    if(moonLanding.weekday == DateTime.sunday){
      print('해당 날짜는 일요일입니다.');
      exceptShowDialog();
      return false;
    }else
      return true;
  }

 ///일요일 경고 Dialog
 exceptShowDialog() {
    return showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline,color: Colors.red,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('설정 불가', textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('일요일은 설정할 수 없습니다.', textScaleFactor: 0.85),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>[
              TextButton(child: new Text("확인",textScaleFactor: 1.0),
                onPressed: () {  Navigator.pop(context);  },
              )
            ],
          );
        });
  }
}
