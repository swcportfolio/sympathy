import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/count_msg.dart';
import 'package:sympathy_app/page/chat/chat_page.dart';
import 'package:sympathy_app/page/setting/satisfaction_page.dart';
import 'package:sympathy_app/utils/common.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';

class ChatListItem extends StatelessWidget {

  final ChatData chatData;
  final Function onBackCallback;
  final int index;
  final Authorization auth;
  final VoidCallback callback;
  final CheckCountMessage checkCountMessage;
  final String senderName;
  ChatListItem(this.chatData, this.index, this.auth, this.onBackCallback, {this.callback, this.checkCountMessage, this.senderName});

  final String imagePath = 'images/man_d.png';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

        if(auth.account == 'C' &&  checkCountMessage.message == '상담이 종료되었습니다.')
        {
          Etc.newShowSnackBar('상담이 종료되어 입장이 불가능 합니다.', context);
        }
        else if(auth.account == 'N' &&  checkCountMessage.message == '상담이 종료되었습니다.')
         {
           Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>SatisfactionPage(auth:auth, requesterID:chatData.peerID, callback:()=>callback())));

         }
        else
          {
          chatData.senderName = senderName;
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
              ChatPage(chatData, auth, callback:()=>callback()))).then((_) { onBackCallback();});
          }

      },
      child: Container(
        color: index % 2 == 0 ? Color(0xFFeeeeee) : Colors.white,
        padding: EdgeInsets.fromLTRB(20, 10, 16, 10),
        child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 10),
                child:
                chatData.profileImg == null ? SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: Image.asset(imagePath, fit: BoxFit.fill)):
                ExtendedImage.network(
                  Common.IMAGE_BASE_URL + chatData.peerID + '/' +chatData.profileImg,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.fill,
                  cache: true,
                  // border: Border.all(color: Colors.red, width: 1.0),
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
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 160.0,
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(chatData.peerName,textScaleFactor: 1.0, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 7.0),
                        Text(checkCountMessage.message, textScaleFactor: 0.92, style: TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis)
                      ]
                  )
              ),
              Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            child: Text(Common.getFormatDate(chatData.sendDT),textScaleFactor: 0.75)),
                        SizedBox(height: 5.0),
                        chatData.unreadCnt == '0'
                            ? Container()

                            : Visibility(
                              visible: checkCountMessage.disabled,
                              child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.red),
                              width: 19.0, height: 19.0,
                              alignment: Alignment.center,
                              child: Text(chatData.unreadCnt,  textScaleFactor:0.75,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.end)
                        ),
                            )
                      ]
                  )
              )
            ]
        ),
      )
      /*
      WrapContainer(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
        padding: EdgeInsets.all(10),
        content: Row(
          children: <Widget>[
            ExtendedImage.network(
              'https://github.com/flutter/plugins/raw/master/packages/video_player/video_player/doc/demo_ipod.gif?raw=true',
              // 'http://106.251.70.71:50000/thumbnail/users/test1/2006091401/2006091401.jpg',
              width: 50.0,
              height: 50.0,
              fit: BoxFit.fill,
              cache: true,
              // border: Border.all(color: Colors.red, width: 1.0),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(25.0),
              // BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
              loadStateChanged: (ExtendedImageState state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    return Image.asset("images/loading.gif", fit: BoxFit.fill);
                  case LoadState.completed:
                    return Image.asset("images/avatar.jpg", fit: BoxFit.fill);
                    // break;
                  case LoadState.failed:
                    return Image.asset("images/loading.gif", fit: BoxFit.fill);
                }

                return null;
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width - 160.0,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(chatData.peerName,
                    style: TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 3.0),
                  Text(chatData.message,
                    style: TextStyle(fontSize: 14.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  )
                ]
              )
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Text(Common.getFormatDate(chatData.sendDT), style: TextStyle(fontSize: 11.0))
                  ),
                  SizedBox(height: 5.0),
                  chatData.unreadCnt == '0'
                  ? Container()
                  : Container(
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red),
                    width: 18.0,
                    height: 18.0,
                    alignment: Alignment.center,
                    child: Text(chatData.unreadCnt, style: TextStyle(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.end)
                  )
                ]
              )
            )
          ]
        ),
      )*/
    );
  }
}

