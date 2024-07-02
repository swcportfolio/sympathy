import 'rest_response.dart';

class Profile {
  String userID;
  String name;
  String gender;
  String email;
  String dateOfBirth;
  String hopeTime;
  String profileImg;
  String testYN;
  String companyName;
  String hopeTime1;
  String hopeTime2;
  String hopeTime3;

  // 스트레스 반응 검사 text 값
  String testResult1;
  String testResult2;
  String testResult3;
  String testResult4;
  String testTotalResult;

  // 스트레스 반응 숫자 값
  String testResultValue1;
  String testResultValue2;
  String testResultValue3;
  String testResultValue4;
  String testTotalResultValue;


  Profile({this.userID,this.name, this.gender, this.dateOfBirth, this.hopeTime, this.profileImg, this.testYN,
    this.companyName, this.hopeTime1, this.hopeTime2, this.hopeTime3 ,this.testResult1, this.testResult2, this.testResult3, this.testResult4, this.testTotalResult
   ,this.testResultValue1, this.testResultValue2, this.testResultValue3, this.testResultValue4, this.testTotalResultValue, this.email});

  factory Profile.fromJson(RestResponseDataMap responseBody) {
    return Profile(
      userID           : responseBody.data['userID'] as String ?? '-',
      name             : responseBody.data['name'] as String ?? '-',
      gender           : responseBody.data['gender'] as String?? '-',
      email            : responseBody.data['phone'] as String?? '-',        //phone 으로 받고 email 로 할당
      dateOfBirth      : responseBody.data['dateOfBirth'] as String?? '-',
      hopeTime         : responseBody.data['hopeTime'] as String?? '-',
      profileImg       : responseBody.data['profileImg'] as String?? '-',
      testYN           : responseBody.data['testYN'] as String?? '-',
      companyName      : responseBody.data['companyName'] as String?? '-',
      hopeTime1        : responseBody.data['hopeTime1'] as String?? '-',
      hopeTime2        : responseBody.data['hopeTime2'] as String?? '-',
      hopeTime3        : responseBody.data['hopeTime3'] as String?? '-',

      // 스트레스 반응 검사 text 값
      testResult1      : responseBody.data['testResult1'] as String?? '-',
      testResult2      : responseBody.data['testResult2'] as String?? '-',
      testResult3      : responseBody.data['testResult3'] as String?? '-',
      testResult4      : responseBody.data['testResult4'] as String?? '-',
      testTotalResult  : responseBody.data['testTotalResult'] as String?? '-',

      // 스트레스 반응 숫자 값
      testResultValue1      : responseBody.data['testResultValue1'] as String?? '-',
      testResultValue2      : responseBody.data['testResultValue2'] as String?? '-',
      testResultValue3      : responseBody.data['testResultValue3'] as String?? '-',
      testResultValue4      : responseBody.data['testResultValue4'] as String?? '-',
      testTotalResultValue  : responseBody.data['testTotalResultValue'] as String?? '-',
    );
  }
}