import 'package:flutter/material.dart';
import 'package:sympathy_app/data/expanded_item.dart';
import 'package:sympathy_app/data/terms.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/widget/button.dart';

//이용약관 화면
class TermsPage extends StatefulWidget {

  final VoidCallback callback;
  TermsPage({this.callback});

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final String title = '이용약관';

  final _termsText = TermsText();
  List<bool> agree = [false, false, false]; //이용약관 동의
  List<ExpandedItem> _data;

  @override
  void initState() {
    super.initState();
    _data = generateItems(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: doAppBar(title),

      body:Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                    [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15,top: 15),
                        child: Text( _termsText.mainTitle, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold), softWrap: true,),
                      ),
                      _buildAgree(0, _termsText.allTitle),
                      SizedBox(height: 8),
                      _buildPanel(),
                    ]
                ),
              ),
            ),
          ),
          Align(alignment:Alignment.bottomCenter,
              child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                  child: TermsButton(btnName: '동의하고 회원가입',context: context, agree:agree, callback:()=> widget.callback())))
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(()
          {
            _data[0].isExpanded = false; // 두개이상 비활성화
            _data[1].isExpanded = false;

            _data[index].isExpanded = !isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((ExpandedItem item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded,) {
              return ListTile(
                title: _buildRowCheckBox(indexInput(item.headerValue), item.headerValue),
              );
            },
            body: Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: ListTile(
                  title: Container(
                      decoration: BoxDecoration(border: Border.all( width: 1.5, color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(1.0))),
                      padding: const EdgeInsets.all(10),
                      height: 150,
                      child: Scrollbar(
                          child: SingleChildScrollView(
                              child: Text(item.expandedValue, softWrap: true, textScaleFactor: 0.75))))),
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }

  // 동의 Widget
  _buildAgree(int index, String headText) {
    return Container(
      height: 70,
      child: Card(color:  Colors.white, elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
          [
            _buildRowCheckBox(index, headText),
          ],
        ),
      ),
    );
  }

  //checkBox input Text
  List<ExpandedItem> generateItems(int numberOfItems) {
    return List<ExpandedItem>.generate(numberOfItems, (int index) {
      return ExpandedItem(
        headerValue: index == 0 ? _termsText.participationTitle:_termsText.privacyTitle,
        expandedValue: index == 0? _termsText.participation:_termsText.privacyMainText,
      );
    });
  }

  _buildRowCheckBox(int index, String headText) {
    return  Row(
      children: [
        Visibility(visible:headText == _termsText.allTitle ? true:false ,child: Container(width: 15)),
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
              activeColor: mainColor,
              checkColor: Colors.white,
              shape: CircleBorder(side: BorderSide(color: mainColor)),
              value: agree[index],
              onChanged:(bool value){
                setState(()
                {
                  if(index == 0)
                  {
                    for(int i = 0 ; i<agree.length ;i++)
                      agree[i] = value;
                  }
                  else{
                    agree[index] = value;
                  }
                });
              }),
        ),
        Container(
            child: Row(
                children:
                [
                  Text(headText,softWrap: true,textScaleFactor:index == 0 ? 1.1:0.8,
                      style: TextStyle(fontWeight: index == 0 ? FontWeight.bold:FontWeight.normal)),
                  Visibility(visible:index == 0 ? false:true,
                      child:Text(' (필수)',softWrap: true, textScaleFactor: 0.7,style: TextStyle(color: Colors.red))),
                ]
            )),
      ],
    );
  }

  //title text 에 맞는 인덱스 input
  int indexInput(String value) {
    if(_termsText.participationTitle == value){
      return 1;
    }else{
      return 2;
    }
  }
}
