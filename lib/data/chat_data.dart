import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'rest_response.dart';

class ChatData with ChangeNotifier {
  String messageType;
  String groupID;
  String senderID;
  String senderName;
  String receiverID;
  String peerID;
  String peerName;
  String nickName;
  String message;
  String sendDT;
  String createDT;
  String icon;
  String unreadCnt;
  String profileImg;

  ChatData({this.profileImg, this.messageType, this.groupID, this.senderID, this.senderName, this.receiverID, this.peerID, this.peerName, this.nickName, this.message, this.sendDT, this.createDT, this.icon, this.unreadCnt});

  factory ChatData.fromString(String data) {
    return ChatData.fromJson(jsonDecode(data));
  }

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return new ChatData(
        messageType: json['messageType'] as String,
        groupID:     json['groupID'] as String,
        senderID:    json['senderID'] as String,
        senderName:  json['senderName'] as String,
        receiverID:  json['receiverID'] as String,
        peerID:      json['peerID'] as String,
        peerName:    json['peerName'] as String,
        nickName:    json['nickName'] as String,
        message:     json['message'] as String,
        createDT:    json['createDT'] as String,
        sendDT:      json['sendDT'] as String,
        icon:        json['icon'] as String,
        unreadCnt:   json['unreadCnt'] as String,
        profileImg:  json['profileImg'] as String
      // direction: json['direction'] as String == null ? '-' : json['direction'] as String,
    );
  }

  static List<ChatData> parse(RestResponse responseBody) {
    return responseBody.data.map<ChatData>((json) => ChatData.fromJson(json)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'messageType': messageType,
      'groupID': groupID,
      'senderID': senderID,
      'senderName': senderName,
      'receiverID': receiverID,
      'message': message,
      'sendDT': sendDT,
      'unreadCnt': unreadCnt
    };
  }

  Map<String, dynamic> toMapForDB() {
    return {
      'messageType': messageType,
      'groupID': groupID,
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'sendDT': sendDT

    };
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }
}