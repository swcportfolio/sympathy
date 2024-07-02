import 'package:flutter/foundation.dart';
import 'package:sympathy_app/data/rest_response.dart';


class UserListData with ChangeNotifier {
  String userID;
  String accountType;
  String name;
  String age;
  String history;
  String info;
  String price;
  String gender;
  String nickname;
  String profileImg;
  int page;
  String dateOfBirth;
  String testYN;
  String dday;
  String hopeTime1;
  String hopeTime2;
  String hopeTime3;


  UserListData({this.dateOfBirth, this.testYN, this.userID,this.accountType,this.name,this.age,this.history,this.page, this.info,
    this.price, this.gender, this.nickname, this.profileImg, this.dday, this.hopeTime1, this.hopeTime2, this.hopeTime3});

  factory UserListData.fromJson(Map<String, dynamic> json) {
    return UserListData(
      userID      : json['userID'] as String ?? '-',
      accountType : json['accountType'] as String ?? '-',
      name        : json['name'] as String ?? '-',
      age         : json['age'] as String ?? '-',
      gender      : json['gender'] as String ?? '-',
      nickname    : json['nickname'] as String ?? '-',
      profileImg  : json['profileImg'] as String ?? '-',
      dateOfBirth : json['dateOfBirth'] as String ?? '-',
      testYN      : json['testYN'] as String ?? '-',
      dday        : json['dday'] as String ?? '-',
      hopeTime1   : json['hopeTime1'] as String ?? '-',
      hopeTime2   : json['hopeTime2'] as String ?? '-',
      hopeTime3   : json['hopeTime3'] as String ?? '-',
    );
  }

  static List<UserListData> parse(RestResponse responseBody) {
    return responseBody.data.map<UserListData>((json) => UserListData.fromJson(json)).toList();
  }
}
class UserDetails {
  String userID;
  String name;
  String address;
  String gender;
  String phone;
  String age;
  String history;
  String coachContents;
  String info;
  String price;
  String profileImg;
  String dateOfBirth; // 생년월일
  String hopeTime1;
  String hopeTime2;
  String hopeTime3;


  UserDetails({this.userID,this.name, this.address, this.gender, this.phone, this.age,
    this.history, this.coachContents, this.info, this.price, this.profileImg, this.dateOfBirth, this.hopeTime1, this.hopeTime2, this.hopeTime3});

  factory UserDetails.fromJson(RestResponseDataMap responseBody) {
    return UserDetails(
      userID        : responseBody.data['userID'] as String ?? '-',
      name          : responseBody.data['name'] as String ?? '-',
      address       : responseBody.data['address'] as String?? '-',
      gender        : responseBody.data['gender'] as String?? '-',
      phone         : responseBody.data['phone'] as String?? '-',
      age           : responseBody.data['age'] as String?? '-',
      history       : responseBody.data['history'] as String?? '-' ,
      coachContents : responseBody.data['coachContents'] as String?? '-',
      info          : responseBody.data['info'] as String?? '-',
      price         : responseBody.data['price'] as String?? '-',
      profileImg    : responseBody.data['profileImg'] as String?? '-',

      dateOfBirth: responseBody.data['dateOfBirth'] as String?? '-', // 생년월일
      hopeTime1: responseBody.data['hopeTime1'] as String?? '-',
      hopeTime2: responseBody.data['hopeTime2'] as String?? '-',
      hopeTime3: responseBody.data['hopeTime3'] as String?? '-',
    );
  }
}
