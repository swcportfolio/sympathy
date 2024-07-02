import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sympathy_app/page/chat/chat_list_page_bar.dart';
import 'package:sympathy_app/page/setting/hope_time.dart';
import 'package:sympathy_app/page/setting/satisfaction_page.dart';
import 'data/authorization.dart';
import 'page/chat/main_page.dart';
import 'page/login/login_page.dart';
import 'page/setting/survey_page.dart';
import 'utils/constants.dart';

Future<void> main() async {

  String userID;
  String password;
  String profileImg;
  String account;
  String testYN;
  String hopeTimeYN;
  Authorization auth;

  WidgetsFlutterBinding.ensureInitialized();

  var pref = await SharedPreferences.getInstance();
   userID = pref.getString('userID');
  if(userID != null){

    userID      = pref.getString( 'userID' );
    password    = pref.getString( 'password' );
    account     = pref.getString( 'account' );
    profileImg  = pref.getString( 'profileImg' );
    testYN      = pref.getString( 'testYN' );
    hopeTimeYN  = pref.getString( 'hopeTimeYN' );

    print( ' -----> userID : '+userID+' / password :'+ password  );

    auth = Authorization( userID:userID, password:password, profileImg:profileImg ,account:account );
  }

  return runApp(MyApp(auth, userID, account, testYN, hopeTimeYN));
}

class MyApp extends StatelessWidget {

  final Authorization auth;
  final String userID;
  final String account;
  final String testYN;
  final String hopeTimeYN;
  final ThemeData theme = ThemeData();

  MyApp(this.auth, this.userID, this.account, this.testYN, this.hopeTimeYN,);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '공감',
      theme: Theme.of(context).copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: mainColor),
          primaryTextTheme:theme.textTheme.apply(fontFamily: 'nanum_square')),

      initialRoute: userID == null? 'login_page':account =='N'? testYN=='Y'?hopeTimeYN=='Y'?'chat_page':'hope_time_page':'survey_page' : 'main_page',

      routes: {
        'login_page'    : (context)  => LoginPage(),
        'main_page'     : (context)  => MainPage(auth, true),
        'survey_page'   : (context)  => SurveyPage(auth:auth),
        'hope_time_page' : (context) => HopeTime(auth:auth),
        'chat_page'     : (context)  => ChatListPageBar(auth, true),
        'test_page'     : (context)  => SatisfactionPage(auth:auth)
      },
    );
  }
}
