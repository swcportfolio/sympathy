import 'authorization.dart';
import 'chat_data.dart';

class SearchDefaultData {
  String groupID;
  String userID;
  String searchStartDate;
  String searchEndDate;
  String data;
  String authorizationToken;
  int pageIndex = 1;

  SearchDefaultData(Authorization auth) {
    this.userID = auth.userID;
    this.authorizationToken = auth.authorizationToken;
  }

  Map<String, dynamic> toMap({int page}) {
    return {
      'groupID': groupID,
      'userID': userID,
      'data': data,
      'searchStartDate': searchStartDate,
      'searchEndDate': searchEndDate,
      'page':page !=null? page:pageIndex,
    };
  }
}