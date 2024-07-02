
class RestResponse {
  Map<String, dynamic> status;
  List<dynamic> data;

  RestResponse({this.status, this.data});

  factory RestResponse.fromJson(Map<String, dynamic> json) {
    return new RestResponse(
        status: json['status'] as Map,
        data: json['data'] as List<dynamic>
    );
  }
}


/// 상세 내용
class RestResponseDataMap {
  Map<String, dynamic> status;
  Map<String, dynamic> data;

  RestResponseDataMap({this.status, this.data});

  factory RestResponseDataMap.fromJson(Map<String, dynamic> json) {
    return new RestResponseDataMap(
        status: json['status'] as Map,
        data: json['data'] as Map
    );
  }
}