import 'package:sympathy_app/data/rest_response.dart';

class Company{
  String code;
  String companyName;

  Company({this.code, this.companyName});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      code: json['code'] as String ?? '-',
      companyName: json['companyName'] as String ?? '-',
    );
  }

  static List<Company> parse(RestResponse responseBody) {
    return responseBody.data
        .map<Company>((json) => Company.fromJson(json))
        .toList();
  }
}