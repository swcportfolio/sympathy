import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/page/setting/satisfaction_page.dart';
import 'package:sympathy_app/utils/common.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';

import 'button.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatData chatData;
  final String name;
  final String account;
  final AnimationController animationController;
  final String imagePath = 'images/man_d.png';
  final Authorization auth;
  final BuildContext chatPageContext;
  final VoidCallback callback;
  String parsingEndMessage;

  ChatMessageItem({this.chatData, this.name, this.account, this.animationController, this.auth, this.chatPageContext, this.callback});

  @override
  Widget build(BuildContext context) {
    Widget _message;

    return animationController != null ? _animationContainer(context) : _normalContainer(context);
  }

  Widget _normalContainer(context) {
    if(chatData.messageType == 'DATE') {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Text(Common.getCustomFormatDate(chatData.sendDT + ' 00:00:00', 'yyyy년 MM월 dd일'), textScaleFactor:0.84, textAlign: TextAlign.center)
              )
            ],
          )
      );
    }

    else {
      if( chatData.message == endMessage && auth.account == 'N' ){ // 상담자가 종료버튼을 누르고, 내담자의 경우 만족도 검사로 화면이 넘어감
        // Fluttertoast.showToast(
        //     msg: "검사가 종료되었습니다. 수고 하셨습니다.\n 만족도검사를 진행해 주시기 바랍니다.",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 15,
        //     backgroundColor: Colors.black38,
        //     textColor: Colors.white,
        //     fontSize: 14.0
        // );

        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>SatisfactionPage(auth:auth, requesterID:chatData.peerID, callback:()=>callback())));
        });
      }

      if(chatData.message == endMessage)//상담사에서보여줄 상담이 종료되었습니다.
      {
       parsingEndMessage = Etc.parsingEndMessage(chatData.message);
       chatData.message = parsingEndMessage;
      }

      return Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: chatData.messageType == 'SEND'? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              chatData.messageType == 'SEND' ? Container() :
              Container(child: chatData.profileImg == null ? SizedBox(width: 40.0, height: 40.0, child: Image.asset(imagePath, fit: BoxFit.fill))
                  :
                  ExtendedImage.network(
                    Common.IMAGE_BASE_URL + chatData.senderID +'/'+ chatData.profileImg,
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.fill,
                    cache: false,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25.0),
                    loadStateChanged: (ExtendedImageState state) {

                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Image.asset(imagePath, fit: BoxFit.fill);
                        case LoadState.completed:
                        // return Image.asset(imagePath, fit: BoxFit.fill);
                          break;
                        case LoadState.failed:
                          return Image.asset(imagePath, fit: BoxFit.fill);
                      }
                      return null;

                    },
                  )
                // CircleAvatar(child: Text(name[0]), radius: 20, backgroundColor: Color(0xFFEEEEEE)),
              ),


              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  chatData.messageType == 'SEND' ? _endWidget() : Container(), // 보낸시간

                  Container(
                    padding: EdgeInsets.only(top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    margin: EdgeInsets.only(top: 7, left: 8, right: 8),
                    decoration: BoxDecoration(
                        color: chatData.messageType == 'SEND' ? mainColor : Color(0xFFEEEEEE), // Color(0xFF56CA8F1),
                        borderRadius: chatData.messageType == 'SEND' ? BorderRadius.only(
                            topLeft: Radius.circular(15.0), topRight: Radius.zero, bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)
                        ): BorderRadius.only(
                            topLeft: Radius.zero, topRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)
                        )
                    ),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.6,
                        minHeight: 30
                    ),
                    child: Text(chatData.message,  textScaleFactor:1.05,style: chatData.messageType == 'SEND' ? TextStyle(color: Colors.white) : TextStyle(color: Color(0xFF363636))),),

                  chatData.messageType == 'SEND' ? Container() : _endWidget() // 보낸시간

                ],
              ),
            ],
          )
      );
    }
  }

  Widget _animationContainer(context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: animationController,
            curve: Curves.fastOutSlowIn
        ),
        axisAlignment: -1.0,
        child: _normalContainer(context)
    );
  }

  Widget _endWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: chatData.messageType == 'SEND' ? MainAxisAlignment.end : MainAxisAlignment.end,
        crossAxisAlignment: chatData.messageType == 'SEND' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(Common.getFormatDate(chatData.sendDT), textScaleFactor:0.75,style: TextStyle(color: Colors.black))
        ],
      ),
    );
  }
}
