import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/survey.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/widget/button.dart';

// 설문 조사 화면
class SurveyPage extends StatefulWidget {
  final Authorization auth;

  SurveyPage({ this.auth}) ;

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {

  final _question = Question();
  List<String>groupValue = [];


  final String title = '설문조사1';
  final String headText  = '* 다음은 여러분이 일상생활에서 스트레스를 받았을 때 경험할 수 있는 것들입니다.\n 지난 일주일 동안 아래의 문항을 어느 정도 경험했는지 해당하는 칸에 체크하십시오.';
  final String headText2  = '* 다음은 어려운 상황을 극복해 낼 수 있는 개인 특성에 관한 문항입니다. 현재 자신이 느끼기에 가장 가깝다고 생각하는 칸에 체크하십시오. (본 설문은 채팅상담 사전, 사후 2회에 걸쳐 실시됩니다.)';
  String headNum; // 설문조사 앞 번호(숫자+Q)
  int addIndex;   // 앞번호 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:doAppBar(title),

      body: Center(
        child: Column(
          children:
          [
            Expanded(
              flex: 8,
              child: Scrollbar(
                child: ListView.builder(
                    itemCount: 37 , // 완료하기 버튼 +1 추가
                    itemBuilder: (BuildContext context, int index){

                      addIndex = index;
                      if(addIndex >= 28){
                        --addIndex;
                        index.bitLength == 2 ? headNum ='Q'+ addIndex.toString().substring(0,1):headNum ='Q'+addIndex.toString();
                      }else{
                        index.bitLength == 2 ? headNum ='Q'+ addIndex.toString().substring(0,1):headNum ='Q'+addIndex.toString();
                      }

                      return index == 0?
                        Container(height: 100, padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Text(headText, textScaleFactor:1.1, style: TextStyle(fontWeight: FontWeight.bold)))
                          :
                        index == 27?
                        Container(height: 110, padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Column(
                                children: [
                                  Etc.solidLine(context),
                                  SizedBox(height: 10),
                                  Container(child: Text(headText2, textScaleFactor:1.1, style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ))
                          :
                        index == 36?
                        Container(child: SurveyButton(btnName: '완료하기',answer: _question.value, context:context, auth: widget.auth))
                          :
                        Center(
                          child:Padding(padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                child: Padding(padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(width: 300,
                                              child: Text(
                                                  index>=28 ? headNum+_question.questionList[--index]:
                                                  headNum+_question.questionList[index], textScaleFactor:1.1, style: TextStyle(fontWeight: FontWeight.bold), softWrap: true)),
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
                                          radioItem(0, index),
                                          radioItem(1, index),
                                          radioItem(2, index),
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
                                            radioItem(3, index),
                                            radioItem(4, index),
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
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Radio Button
  radioItem(int answer, int groupIndex){
    //print('radioItem index : '+groupIndex.toString());
      return Row(
        children:
        [
          Radio(
              activeColor:mainColor,
              value: answer.toString(),
              groupValue: _question.value[groupIndex],
              onChanged: (value)
              {
                setState(()
                {
                    _question.value[groupIndex] = value;
                });
              }),
          Text(_question.answer[answer],textScaleFactor: 1.0),
        ],
      );
  }
}
