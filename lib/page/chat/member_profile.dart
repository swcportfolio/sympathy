import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/profile.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/button.dart';

class MemberProfile extends StatefulWidget {

  final Authorization auth;
  final UserListData _userListData;
  final bool identification;// 나의 내담자: true,  내담자 찾기: false
  final String senderName;

  MemberProfile(this._userListData, this.auth, this.identification, {this.senderName});

  @override
  _MemberProfileState createState() => _MemberProfileState();
}
class _MemberProfileState extends State<MemberProfile> {

 Profile _profile = Profile();
 final String title = '내담자 프로필';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar(title),

      body: Stack(
        children: [
          FutureBuilder(
            future: client.getProfile(widget._userListData.userID, 'N'),
            builder:(context,snapshot){

              if(snapshot.hasError) {
                return Container(
                    child: Center(
                        child: Text(snapshot.error.toString().replaceFirst('Exception: ', ''),
                            style: TextStyle(color: Colors.white, fontSize: 20.0))
                    )
                );
              }
              if(!snapshot.hasData) {
                return Container(
                    child: Center(
                        child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                            )
                        )
                    )
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                _profile = snapshot.data;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(top: 40,bottom: 10),
                      child: SizedBox(height: 90.5, width: 90.5,
                        child: Etc.imageCircle(widget._userListData),
                      ),
                    ),

                    buildHeadText('survey.png' , '내담자 정보'),

                    Padding(padding: const EdgeInsets.fromLTRB(33, 10, 33, 10),
                      child: Container(
                          height: 290,
                          width:MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(border: Border.all( width: 2.0,color: mainColor,),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Padding(padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              profileItem('이름'   , _profile.name+'( ${_profile.gender} )'),
                              Etc.solidLine(context),
                              profileItem('설문여부', Etc.ynConvert(_profile.testYN)),
                              Etc.solidLine(context),
                              profileItem('이메일'   , _profile.email),
                              Etc.solidLine(context),
                              profileItem('생년월일', _profile.dateOfBirth),
                              Etc.solidLine(context),
                              profileItem('직업 명', _profile.companyName),


                            ],
                          ),
                        )
                      ),
                    ),

                    buildHeadText('time.png'   , '상담 가능시간'),

                    Padding(padding: const EdgeInsets.fromLTRB(33, 10, 33, 10),
                      child: Container(
                          height: 190,
                          width:MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(border: Border.all( width: 2.0,color: mainColor,),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Padding(padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                profileItem('1 순위'   , _profile.hopeTime1+'시'),
                                Etc.solidLine(context),
                                profileItem('2 순위'   , _profile.hopeTime2+'시'),
                                Etc.solidLine(context),
                                profileItem('3 순위'   , _profile.hopeTime3+'시'),


                              ],
                            ),
                          )
                      ),
                    ),
                    buildHeadText('stress.png' , '스트레스 반응'),
                    Padding(padding: const EdgeInsets.fromLTRB(33, 10, 33, 20),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                            height: 160,
                            decoration: BoxDecoration(border: Border.all( width: 2.0,color: mainColor,),
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: DataTable(
                              columns:
                              [
                                DataColumn(label: Text('신체화', textScaleFactor: 1.45, style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('우울',textScaleFactor: 1.45,style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('분노',textScaleFactor: 1.45,style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('직무',textScaleFactor: 1.45,style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('총점',textScaleFactor: 1.45,style: TextStyle(fontWeight: FontWeight.bold))),
                              ],

                              rows: [
                                DataRow(
                                    cells:
                                    [
                                      DataCell(Text(_profile.testResult1, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResult2, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResult3, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResult4, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testTotalResult, textScaleFactor: 1.3)),
                                    ]
                                ),
                                DataRow(
                                    cells:
                                    [
                                      DataCell(Text(_profile.testResultValue1, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResultValue2, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResultValue3, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testResultValue4, textScaleFactor: 1.3)),
                                      DataCell(Text(_profile.testTotalResultValue, textScaleFactor: 1.3)),
                                    ]
                                ),

                              ])
                        ),
                      ),
                    ),
                    
                    Padding(padding: const EdgeInsets.fromLTRB(33, 20, 33, 20),
                      child: ChattingButton(text:'상담하기',auth:widget.auth, userListData:widget._userListData,
                        identification:widget.identification, callback: ()=>showSnackBarEnrollment(), senderName:widget.senderName),
                    ),

                    Visibility(
                      visible: widget.identification,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(33, 0, 33, 30),
                        child: ExcludingMembersButton('상담 취소하기', widget.auth, widget._userListData,()=>showSnackBarCancel()),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 내담자 찾기 화면에서 등록 했을 경우
  showSnackBarEnrollment(){
    Etc.newShowSnackBar('등록이 완료 되었습니다.', context);
  }

 /// 내담자 취
 showSnackBarCancel(){
   Etc.newShowSnackBar('상담이 취소되었습니다. ', context);
 }

  /// 문단별 텍스트
  Padding buildHeadText(String imageName, String text) {
    return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 25,width: 25,
                            child: Image.asset(imageName,)),
                        SizedBox(width: 10),
                        Text(text,textScaleFactor: 1.03),
                      ],
                    ),
                  );
  }


  ///이름, 성별, 생년월일
  profileItem(String textTitle, String value){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
        [
          Row(
            children:
            [
              Image.asset('uu.png', width: 10, height: 10,),
              SizedBox(width: 10),
              Text(textTitle,textScaleFactor:0.95, style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          Text(value, textScaleFactor:0.9),
        ],
      ),
    );
  }
}

