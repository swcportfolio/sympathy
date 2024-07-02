import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sympathy_app/data/company.dart';
import 'package:sympathy_app/data/gridview.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/etc.dart';
import 'package:sympathy_app/utils/edit_controller.dart';
import 'package:sympathy_app/widget/button.dart';
import 'package:sympathy_app/widget/widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sympathy_app/utils/validators.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

/// 회원가입 화면
class SignUpPage extends StatefulWidget {

  final String title = '회원 가입';
  final VoidCallback callback; // 회원가입 완료 메시지 callback 함수
  SignUpPage({this.callback});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {

  GridViewGender _gridViewGender = GridViewGender(); // 성별 GridView
  //FocusNode _focusNodeCode = FocusNode();            // 인증코드 포커싱
  ImagePicker _picker  = ImagePicker();              // 이미지 피커
  SignEdit editSignCnt = SignEdit();                 // 회원가입 입력 edit

  File imageFile, defaultImage;

  List<Company> _companyData = []; // 회사 명, 코드 리스트
  List<String> _companyName = [];  // 회사명 리스트
  List<String> _code = [];         // 회사 코드 리스트

  String base64Str, defaultImage64Str, base64; //Image Base64
  String dateOfBirth;
  String _selectedCompanyName;
  String gender;// Gridview 성별

  bool isPossibleEmail = false;  // 메일 중복 체크

 // bool isNotState = true;        // 회사 코드 재호출 방지
 // bool codeVerification = false; // 코드 인증이 완료되야 true

  @override
  void initState() {
    super.initState();

    imageToFile(imageName:'sign_profile_image', ext:'png'); // 초기 defaultImage
    dateOfBirth = '날짜를 선택해주세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: Text(widget.title, textScaleFactor: 0.9, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body:  GestureDetector(
        onTap: ()
        {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children:
                [
                  _buildSignItem(),
                  SignButton(text: '회원 가입', editSignCnt:editSignCnt, context:context, gender:gender,
                      base64Str:base64Str, defaultImage64Str:defaultImage64Str, callback:()=>widget.callback(),
                      dateOfBirth:dateOfBirth,isPossibleEmail:isPossibleEmail),
                  SizedBox(height: 30.25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 // 회원가입 Item
  _buildSignItem() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 1, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
              [
                Stack(
                children:
                [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 38.5, 0, 0.5),
                      child: CircleAvatar(backgroundColor: Colors.white, radius: 45,
                        backgroundImage: imageFile == null ? AssetImage('images/sign_profile_image.png') : FileImage(File(imageFile.path)))),
                    Positioned(right: 10, bottom: 5,
                        child: Container(height: 25, width: 25,
                          child: InkWell(
                              onTap: () =>
                              {
                                bottomSheet()
                              },
                              child: Icon(Icons.camera_alt)),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)))))
                ]),
              ],
            ),
            SizedBox(height: 38),
            SignInputEdit(controller: editSignCnt.idController    , iconData: Icons.account_box, headText: '아이디', hint: '5자 이상 입력해주세요.', type: 'id'),
            SignInputEdit(controller: editSignCnt.passController  , iconData: Icons.vpn_key, headText: '비밀번호', hint: '비밀번호 8자 이상 입력해주세요.', type: 'pass'),
            SignInputEdit(controller: editSignCnt.pass2Controller , iconData: Icons.vpn_key, headText: '비밀번호 확인', hint: '비밀번호 재 입력해주세요.', type: 'pass'),
            SizedBox(height: 30),
            Row(
              children:
              [
                Expanded(child: SignInputEdit(controller: editSignCnt.emailController , iconData: Icons.email, headText: '* 이메일(기프티콘 발송을 위해 메일 주소를 정확히 기입해 주세요.)', hint: 'ex) 1234@naver.com', type: 'company')),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 44),
                  child: SizedBox(height:45,width: 70,
                      child: TextButton(
                          style:TextButton.styleFrom(backgroundColor: mainColor, elevation: 1),
                          onPressed: () async
                          {
                            CheckValidate().validateEmail(editSignCnt.emailController.text, context).then((value) =>
                                setState(() {
                                  isPossibleEmail = value;
                                  FocusScope.of(context).unfocus();
                                })
                            );
                          },
                          child: Text('중복확인',textScaleFactor: 0.8, style: TextStyle(color: Colors.white)))),
                )
              ],
            ),
            SignInputEdit(controller: editSignCnt.nameController  , iconData: Icons.assignment_outlined, headText: '이름', hint: '이름를 입력해주세요.', type: 'name'),
            buildTextBox('생년월일', Icons.date_range, dateOfBirth),
            SignInputEdit(controller: editSignCnt.jobController , iconData: Icons.work, headText: '직업 명', hint: '직업 명을 입력해주세요.', type: 'company'),

            // CheckCodeEdit(codeController: editSignCnt.codeController, selectedCompanyName:editSignCnt.companyController, code: _code ,
            //     companyName:_companyName, context: context, callback:()=>buildVerification(), focusNode:_focusNodeCode),

            SizedBox(height: 30),
            Text('성별', textScaleFactor: 0.94, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 7, 0, 20),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _gridViewGender.cardNames.length,
                        itemBuilder: (BuildContext context, int index)
                        {
                          return buildGridViewGender(index);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)))),
          ],
        ),
      ),
    );
  }

  //인증코드 승인 setState
  // buildVerification(){
  //   setState(()
  //   {
  //     codeVerification = true;
  //     print('[codeVerification] ::'+codeVerification.toString());
  //   });
  // }

  // 성별 선택
  Widget buildGridViewGender(int index) {
    String name = _gridViewGender.cardNames[index];
    return GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();

            if (_gridViewGender.isGender[index]) {
              _gridViewGender.isGender[index] = false;
              gender = '';
            } else  {
              for(int i=0 ; i<_gridViewGender.isGender.length ; i++){
                if(index != i){
                  _gridViewGender.isGender[i] = false;
                }
              }
              _gridViewGender.isGender[index] = true;
              gender = _gridViewGender.cardNames[index];
            }
          }
          );},
        child:Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(1),
              child: Card(
                color: _gridViewGender.isGender[index] ? genderColor : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2),),
                child: Container(height: 40, width: 150,
                  child: Center(child: Text(name, textScaleFactor:0.9, style: TextStyle(color: _gridViewGender.isGender[index] ? Colors.white : Colors.black, fontSize: 14))),
                ),
              ),
            ),
          ],
        )
    );
  }

  //이미지 파일 -> 파일형으로 변환
  Future<void> imageToFile({String imageName, String ext}) async {
    var bytes = await rootBundle.load('images/$imageName.$ext');
    String tempPath = (await getTemporaryDirectory()).path;
    defaultImage  = File('$tempPath/sign_profile_image.png');

    await defaultImage.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    List<int> imageBytes = defaultImage.readAsBytesSync();
    defaultImage64Str = base64Encode(imageBytes);
  }

  // 프로필 사진 선택
  bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Text('Choose Profile photo',style: TextStyle(fontSize: 20)),
          Row(
            children: [
              IconButton(
                  onPressed:takePhoto(ImageSource.gallery),
                  icon: Icon(Icons.photo_library, size: 50)
              )
            ],
          )
        ],
      ),
    );
  }
  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source, imageQuality: 80, maxHeight: 500, maxWidth: 400);
    setState(()
    {
      imageFile = File(pickedFile.path);
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Str = base64Encode(imageBytes);
    });
  }

  buildTextBox(String headText, IconData iconData, String hint, {int identifier}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 19, 0, 5),
          child: Text(headText == '생년월일'? headText: identifier.toString()+ '순위 '+headText,textScaleFactor: 0.94,
              style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold))),
        InkWell(
          onTap: (){
            FocusScope.of(context).unfocus();

            if(hint == dateOfBirth) {
              DatePicker.showDatePicker(context,
                  theme: DatePickerTheme(
                    itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:14),
                    doneStyle: TextStyle(color: Colors.black, fontSize: 14),
                    cancelStyle: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  showTitleActions: true,
                  minTime: DateTime(1900, 01, 01),
                  maxTime: DateTime.now(),
                  onChanged: (date) {
                    print('change $date');
                  },
                  onConfirm: (date) {
                    print('confirm $date');
                    setState(() {

                      dateOfBirth = date.year.toString() + '-' + date.month.toString() + '-' + date.day.toString();

                    });
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.ko);
            }
          },
          child: Container(
            alignment: Alignment.centerLeft,
            height: 47.0,
            child: Padding(padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                    child: Icon(iconData, color: mainColor)),
                  Text(hint,textScaleFactor: 0.9, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            decoration: BoxDecoration(border: Border.all( width: 1.0,color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        )
      ],
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

//Padding(
//   padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
//   child: Text('회사명',textScaleFactor: 0.94, style: TextStyle(fontWeight: FontWeight.bold)),
// ),
//
// Container(
//   height: 55,
//   child: FormField<String>(
//     builder: (FormFieldState<String> state) {
//       return InputDecorator(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
//         child: DropdownButton<String>(
//           isExpanded: true,
//           focusColor:Colors.white,
//           value: _selectedCompanyName,
//           iconEnabledColor:Colors.black,
//           style: TextStyle(color: Colors.white),
//           underline: Container(),
//           items: _companyName.map<DropdownMenuItem<String>>((String value) {
//
//             return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value, textScaleFactor:0.9, style:TextStyle(color:Colors.black)));
//
//           }).toList(),
//           hint:Text("회사를 선택해 주세요.", textScaleFactor:0.9, style: TextStyle(color: Colors.grey, fontFamily: 'OpenSans')),
//           onChanged: (String value) {
//             setState(() {
//               _focusNodeCode.requestFocus();
//               _selectedCompanyName = value;
//             });
//           },
//         ),
//       );
//     },
//   ),
// ),