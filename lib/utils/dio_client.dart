import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/chat_data.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/company.dart';
import 'package:sympathy_app/data/login.dart';
import 'package:sympathy_app/data/profile.dart';
import 'package:sympathy_app/data/rest_response.dart';
import 'package:sympathy_app/data/search_default_data.dart';


const API_PREFIX = 'http://106.251.70.71:50006/ws';  // 실제 사용하는 서버
Client client = Client();

class Client{
  int pageCnt;

  Dio _createDio(String authorizationToken) {
    Dio dio = Dio();
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 5000;

    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': authorizationToken
    };

    return dio;
  }

  /// 로그인
  Future<LoginData> dioLogin(Map<String, dynamic> data) async {
    LoginData loginData = LoginData();

    try {
      print('Call : $API_PREFIX/public/user/login');

      Response response = await Dio().post('$API_PREFIX/public/user/login', data: data);

      if (response.statusCode == 200) {
        print('====> 로그인 : '+ response.data['status']['message']);

        if (response.data['status']['code'] == '200') {
          print('====> account type : '+response.data['data']['accountType']);

          loginData.accountType = response.data['data']['accountType'];
          loginData.token       = response.data['data']['token'];
          loginData.profileImg  = response.data['data']['profileImg'];
          loginData.testYN      = response.data['data']['testYN'];
          loginData.hopeTimeYN  = response.data['data']['hopeTimeYN'];

          return loginData;

        } else {
          print('response data error');
        }
      } else {
        print('checkSign Response statusCode ::'    + response.statusCode.toString());
        print('checkSign Response statusMessage ::' + response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return loginData;
  }

  /// 회원가입
  Future<String> dioSign(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/public/user/insert');
      Response response =
      await Dio().post('$API_PREFIX/public/user/insert', data: data);

      if (response.statusCode == 200) {
        print(response.data['status']['message']);

        if (response.data['status']['code'] == '200') {
          print(response.statusCode);

          if (response.data['status']['message'] == 'Success') {
            print(response.data['status']['message']);
            return 'Success';
          }

        } else if (response.data['status']['code'] == 'ERR_EVS_8013') {
          print(response.data['status']['code'].toString());
          return '중복된 아이디입니다.';
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  Future<List<ChatData>> getChatDataList(SearchDefaultData searchData) async {
    List<ChatData> chatDataList = [];
    try{
      Response response = await _createDio(searchData.authorizationToken).get('$API_PREFIX/chat/data/list', queryParameters: searchData.toMap());
      // Response response = await Dio().get('$API_PREFIX/user/data/list');
      print(response.data);
      // print(response.data['status'].toString());
      // print(response);

      if(response.statusCode == 200)
      {
        if(response.data['status']['code'] == '200')
        {
          chatDataList = ChatData.parse(RestResponse.fromJson(response.data));
          int totalDataCount = response.data['totalDataCount'];
          pageCnt = totalDataCount ~/ 15;
        }
      }
      else
      {
        print(response.statusCode);
        print(response.statusMessage);
        if(response.statusCode == 500) throw new Exception('서버 내부 오류');
        else                           throw new Exception('서버 연결 오류');
      }
    } on DioError catch(e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch(e) {
      print(e.toString());
    }

    // print('length : ' + userDataList.length.toString());

    return chatDataList;
  }
  Future<List<ChatData>> getChatRecentDataList(SearchDefaultData searchData,int pageIndex) async {
    List<ChatData> chatDataList = [];
    print('Call : $API_PREFIX/chat/recent/data/list');
    try{
      Response response = await _createDio(searchData.authorizationToken).get('$API_PREFIX/chat/recent/data/list', queryParameters: searchData.toMap(page:pageIndex));

      if(response.statusCode == 200)
      {
        if(response.data['status']['code'] == '200')
        {
          chatDataList = ChatData.parse(RestResponse.fromJson(response.data));
          int totalDataCount = response.data['totalDataCount'];
          pageCnt = totalDataCount ;
        }
      }
      else
      {
        print(response.statusCode);
        print(response.statusMessage);
        if(response.statusCode == 500) throw new Exception('서버 내부 오류');
        else                           throw new Exception('서버 연결 오류');
      }
    } on DioError catch(e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch(e) {
      print(e.toString());
    }

    // print('length : ' + userDataList.length.toString());

    return chatDataList;
  }

  Future<List<UserListData>> getUserDataList( { int page, String name, String dateOfBirth, String hopeTime1, String hopeTime2, String status, String requesterID}) async {
    List<UserListData> userListData = [];
    Authorization authorization = Authorization();
    userListData.clear();
    print('Call : $API_PREFIX/private/user/list');

   if(hopeTime1 != null)
     print('hopeTime1:'+hopeTime1.toString()+' / hopeTime2'+hopeTime2.toString());
   else
     print('hopeTime1 Null');

    try {
      print('page:'+page.toString());
      Response response = await _createDio(authorization.authorizationToken)
          .get('$API_PREFIX/private/user/list?',
          queryParameters: {'accountType': 'N', 'page':page, 'name':name, 'dateOfBirth':dateOfBirth, 'hopeStartTime':hopeTime1,'hopeEndTime':hopeTime2, 'status':status ,'requesterID':requesterID});

      if (response.statusCode == 200) {

        if (response.data['status']['code'] == '200') {
          userListData = UserListData.parse(RestResponse.fromJson(response.data));

        }
      } else {
        print(response.statusCode);
        print(response.statusMessage);
        if (response.statusCode == 500)
          throw new Exception('서버 내부 오류');
        else
          throw new Exception('서버 연결 오류');
      }
    } on DioError catch (e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return userListData;
  }

  Future<UserDetails> getUserDetails(String userID, String accountType) async {
    UserDetails userDetails = UserDetails();
    Authorization authorization = Authorization();
    Response response;
    print('Call : $API_PREFIX/private/user/get');
    try {
      response = await _createDio(authorization.authorizationToken).get(
          '$API_PREFIX/private/user/get',
          queryParameters: {'userID': userID, 'accountType': accountType});

      if (response.statusCode == 200) {
        print('statusCodeDetails == 200');

        if (response.data['status']['code'] == '200') {
          userDetails = UserDetails.fromJson(RestResponseDataMap.fromJson(response.data));
          return userDetails;
        }
      } else {
        print(response.statusCode);
        print(response.statusMessage);
        if (response.statusCode == 500)
          throw new Exception('서버 내부 오류');
        else
          throw new Exception('서버 연결 오류');
      }
    } on DioError catch (e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return userDetails;
  }

  ///내담자 프로필
  Future<Profile> getProfile(String userID, String accountType) async {
    Profile _profile = Profile();
    Authorization authorization = Authorization();
    Response response;
    try {
      response = await _createDio(authorization.authorizationToken).get(
          '$API_PREFIX/private/user/get',
          queryParameters: {'userID': userID, 'accountType': accountType});

      if (response.statusCode == 200) {

        if (response.data['status']['code'] == '200') {
          _profile = Profile.fromJson(RestResponseDataMap.fromJson(response.data));
          return _profile;
        }
      } else {
        print(response.statusCode);
        print(response.statusMessage);
        if (response.statusCode == 500)
          throw new Exception('서버 내부 오류');
        else
          throw new Exception('서버 연결 오류');
      }
    } on DioError catch (e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return _profile;
  }

  /// 설문조사
  Future<String> dioSurvey(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/stress/test/answer/insert');
      Response response =
      await Dio().post('$API_PREFIX/private/stress/test/answer/insert', data: data);

      if (response.statusCode == 200) {
        print(response.data['status']['message']);

        if (response.data['status']['code'] == '200') {
          print(response.statusCode);

          if (response.data['status']['message'] == 'Success') {
            print(response.data['status']['message']);
            return 'Success';
          }
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  ///나의 내담자 리스트 등록하기
  Future<String> commitRequest(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX private/user/request');
      //
      Response response =
      await Dio().post('$API_PREFIX/private/user/request', data: data);

      if (response.statusCode == 200) {

        if (response.data['status']['code'] == '200') {
          print(response.statusCode);
          print(response.data['status']['message']);

          return response.data['status']['message'];
        }

        else if(response.data['status']['code'] == 'ERR_EVS_8013'){
          return '이미 등록된 내담자 입니다.';
        }

        else {
          print('response data error');
        }

      }

      else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  Future<List<Company>> getCompanyCode() async {
    List<Company> companyData = [];
    Authorization authorization = Authorization();
    companyData.clear();
    print('Call : $API_PREFIX/public/company/list');

    try {
      Response response = await _createDio(authorization.authorizationToken)
          .get('$API_PREFIX/public/company/list');

      if (response.statusCode == 200) {
        print('statusCode == 200');

        if (response.data['status']['code'] == '200') {
          companyData =
              Company.parse(RestResponse.fromJson(response.data));

        }
      } else {
        print(response.statusCode);
        print(response.statusMessage);
        if (response.statusCode == 500)
          throw new Exception('서버 내부 오류');
        else
          throw new Exception('서버 연결 오류');
      }
    } on DioError catch (e) {
      print(e.toString());
      throw new Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return companyData;
  }

  ///상담시간 업데이트
  Future<String> hopeTimeUpdate(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/hopetime/update');

      Response response = await Dio().post('$API_PREFIX/private/hopetime/update', data: data);

      if (response.statusCode == 200) {
        print(response.statusCode);
        print('Data Check : '+response.data['status']['code'].toString());

        if (response.data['status']['code'] == '200') {
          print(response.data['status']['message']);

          return response.data['status']['message'];
        } else {
          if(response.data['status']['code'] == 'ERR_MS_6002'){
            return response.data['status']['code'];
          }
          print('response data error');
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return '';
  }


  ///회원 탈퇴
  Future<String> deleteUser(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/user/delete');

      Response response = await Dio().post('$API_PREFIX/private/user/delete', data: data);

      if (response.statusCode == 200) {
        print(response.statusCode);
        print('Data Check'+response.data['status']['code'].toString());

        if (response.data['status']['code'] == '200') {
          print(response.data['status']['message']);

          return response.data['status']['message'];
        } else {
          print('response data error');
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return '';
  }

  /// 만족도 검사
  Future<String> dioSatisfaction(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/satisfaction/survey/insert');
      Response response = await Dio().post('$API_PREFIX/private/satisfaction/survey/insert', data: data);

      if (response.statusCode == 200) {
        print(response.data['status']['message']);

        if (response.data['status']['code'] == '200') {
          print(response.statusCode);

          if (response.data['status']['message'] == 'Success') {
            print(response.data['status']['message']);
            return 'Success';
          }
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  ///패스워드 업데이트
  Future<String> passUpdateDio(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/user/update');

      Response response = await Dio().post('$API_PREFIX/private/user/update', data: data);

      if (response.statusCode == 200) {
        print(response.statusCode);
        print('Data Check'+response.data['status']['code'].toString());

        if (response.data['status']['code'] == '200') {
          print(response.data['status']['message']);

          return response.data['status']['message'];
        } else {
          print('response data error');
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return '';
  }

  ///나의 내담자 리스트 취소하기
  Future<String> commitRequestCancel(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/private/user/request/cancel');
      Response response = await Dio().post('$API_PREFIX/private/user/request/cancel', data: data);

      if (response.statusCode == 200) {

        if (response.data['status']['code'] == '200') {
          print(response.statusCode);
          print(response.data['status']['message']);

          return response.data['status']['message'];
        }

        else if(response.data['status']['code'] == 'ERR_EVS_8013'){
          return '이미 취소 되었습니다.';
        }

        else {
          print('response data error');
        }
      }
      else {
        print('checkSign Response statusCode ::' + response.statusCode.toString());
        print('checkSign Response statusMessage ::' + response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  ///이메일 중복 체크
  Future<String> checkEmail(Map<String, dynamic> data) async {
    try {
      print('Call : $API_PREFIX/public/mail/check');

      Response response = await Dio().post('$API_PREFIX/public/mail/check', data: data);

      if (response.statusCode == 200) {
        print(response.statusCode);
        print('Data Check'+response.data['status']['code'].toString());

        if (response.data['status']['code'] == '200') {
          print(response.data['status']['message']);

          return response.data['status']['message'];
        } else {
          print('response data error');
          return 'API Error';
        }
      } else {
        print('checkSign Response statusCode ::' +
            response.statusCode.toString());
        print('checkSign Response statusMessage ::' +
            response.statusMessage.toString());
      }
    } on DioError catch (e) {
      print(e.toString());
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return '';
  }
}





