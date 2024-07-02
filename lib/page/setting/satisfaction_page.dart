import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/satisfaction.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/widget/button.dart';

class SatisfactionPage extends StatefulWidget {

  final Authorization auth;
  final VoidCallback callback;
  final String requesterID;
  SatisfactionPage({this.auth, this.requesterID, this.callback});

  @override
  _SatisfactionPageState createState() => _SatisfactionPageState();
}

class _SatisfactionPageState extends State<SatisfactionPage> {

  final String title = '설문조사2';
  final String guideContent = '수고하셨습니다!!\n상담이 종료 되었습니다. 최종적으로 평가 문항 및 만족도 검사를 진행해주시기 바랍니다.';
  final _question = Satisfaction();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      guideDialog('안내', context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar(title),

      body: SingleChildScrollView(
        child: Container(
          color: satisfactionBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(' 다음은 어려운 상황을 극복해 낼 수 있는 개인 특성에 관한 문항입니다. 현재 자신이 느끼기에 가장 가깝다고 생각하는 칸에 체크하십시오. (본 설문은 채팅상담 사전, 사후 2회에 걸쳐 실시됩니다.)',
                          textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold),softWrap: true,),
                      )),
                ],
              ),
              _buildResilience('Q1', _question.resilienceQuestion[0], 0),
              _buildResilience('Q2', _question.resilienceQuestion[1], 1),
              _buildResilience('Q3', _question.resilienceQuestion[2], 2),
              _buildResilience('Q4', _question.resilienceQuestion[3], 3),

              _buildResilience('Q5', _question.resilienceQuestion[4], 4),
              _buildResilience('Q6', _question.resilienceQuestion[5], 5),
              _buildResilience('Q7', _question.resilienceQuestion[6], 6),
              _buildResilience('Q8', _question.resilienceQuestion[7], 7),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(' 상담이 종료 되었습니다. 아래의 상담만족도 검사를 실시 해주세요.', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold),softWrap: true,),
                      )),
                ],
              ),

              buildQuestionItem(headNum:'Q1', index:0),
              buildQuestionItem(headNum:'Q2', index:1),
              buildQuestionItem(headNum:'Q3', index:2),

              Container(padding: const EdgeInsets.all(10.0),
                  child: Text('[ 알림 ]  상담 내용은 삭제 됩니다.', textScaleFactor: 1.0, style: TextStyle(fontWeight: FontWeight.bold, color:Colors.red))),

              Container(child: SatisfactionButton(btnName: '완료하기',answer: _question.value, resilienceAnswer:_question.resilienceValue,
                  context:context, auth: widget.auth, requesterID:widget.requesterID, callback:()=>widget.callback())),
            ],
          ),
        ),
      ),
    );
  }

  buildQuestionItem({String headNum, int index}){
    return Center(
      child:Padding(padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Padding(padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(headNum, textScaleFactor: 1.2, style: TextStyle(color:mainColor ,fontWeight: FontWeight.bold)),
                      SizedBox(width: 2),
                      Text(_question.question[index], textScaleFactor: 0.95, softWrap: true,),
                    ],
                  ),
                  SizedBox(height: 10),

                  Etc.solidLine(context),
                  SizedBox(height: 10),
                  FittedBox(fit: BoxFit.fitWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        radioItem(0, index),
                        radioItem(1, index),
                        radioItem(2, index),
                        Container(width: 30)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  radioItem(int answer,int groupIndex){
    return
      Row(
        children: [
          Radio(
              activeColor:mainColor,
              value: answer.toString(), groupValue: _question.value[groupIndex], onChanged: (value) { setState(() { _question.value[groupIndex] = value; });}),

          Text(_question.answer[answer], textScaleFactor: 0.88,),
        ],
      );
  }

  _buildResilience(String headNum, String text, int index) {
    return Center(
      child:Padding(padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Padding(padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(headNum, textScaleFactor: 1.2, style: TextStyle(color:mainColor ,fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Container(width: 278,
                          child: Text(text, textScaleFactor:0.95, softWrap: true)),
                    ],
                  ),
                  SizedBox(height: 10),

                  Etc.solidLine(context),

                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                      [
                        resilienceRadioItem(0, index),
                        resilienceRadioItem(1, index),
                        resilienceRadioItem(2, index),
                        Container(width: 30)
                      ],
                    ),
                  ),

                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      child: Row(
                        children:
                        [
                          resilienceRadioItem(3, index),
                          resilienceRadioItem(4, index),
                          Container(
                            child: Row(
                              children:
                              [
                                Container(width: 155),
                                //Text('',textScaleFactor: 1.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Radio 라질리언스 문항
  resilienceRadioItem(int answer, int groupIndex){
    print('radioItem index : '+groupIndex.toString());
    return Row(
      children:
      [
        Radio(
            activeColor:mainColor,
            value: answer.toString(),
            groupValue: _question.resilienceValue[groupIndex],
            onChanged: (value)
            {
              setState(()
              {
                _question.resilienceValue[groupIndex] = value;
              });
            }),
        Text(_question.resilienceAnswer[answer],textScaleFactor: 1.0),
      ],
    );
  }

  guideDialog(String title, BuildContext mainContext) {
    return showDialog(context: mainContext, barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_late_outlined,color: mainColor),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(title, textScaleFactor: 0.85, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            content:Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width: 240,
                      child: Text(guideContent, textScaleFactor: 0.85, style: TextStyle(height:1.4))),
                ],
              ),
            ),
            contentPadding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0,0.0),
            actions: <Widget>[
              TextButton (
                child: new Text("확인", textScaleFactor: 1.0),
                onPressed: ()
                {
                  Navigator.pop(context);
                 // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (route) => false);
                },
              ),
            ],
          );
        });
  }
}
