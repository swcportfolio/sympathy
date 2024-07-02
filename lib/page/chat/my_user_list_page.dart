import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/data/hope_time.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/utils/web_socket_client.dart';
import 'package:sympathy_app/widget/widget.dart';

class MyUserListPage extends StatefulWidget {

  final Authorization auth;
  final String name, dateOfBirth;    // 내담자 검색 data
  final bool identification;         // 나의 내담자: true,  내담자 찾기: false
  final String requesterID;          // 상담사 ID
  final String status;               // 나의 내담자 R
  final String hopeTime1, hopeTime2; // 상담시간 검색
  int pageIndexInit;

  MyUserListPage(this.auth, this.name, this.dateOfBirth, this.hopeTime1, this.hopeTime2 ,{ this.identification, this.requesterID , this.status, this.pageIndexInit});

  @override
  _MyUserListPageState createState() => _MyUserListPageState();
}

class _MyUserListPageState extends State<MyUserListPage> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  List<UserListData> userListData    = [];
  List<UserListData> newUserListData = [];
  ScrollController _scrollController = ScrollController();

  int pageIndex = 1;

  UserDetails userDetails = UserDetails();

  @override
  void initState() {
    super.initState();

    _getSenderName(); // 내이름 가져오기

    _scrollController.addListener(() { // page Scroll
      if(_scrollController.offset == _scrollController.position.maxScrollExtent){

        if(userListData.length%10 == 0)
          {
            ++widget.pageIndexInit;
            print('----> my user list pageCount : '+ widget.pageIndexInit.toString());

            _refreshList();
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: client.getUserDataList(page:widget.pageIndexInit, name:widget.name,
              dateOfBirth:widget.dateOfBirth, hopeTime1:widget.hopeTime1, hopeTime2:widget.hopeTime2, requesterID:widget.requesterID, status:widget.status),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                  child: Center(
                      child: Text(snapshot.error.toString().replaceFirst('Exception: ', ''),
                          style: TextStyle(
                              color: Colors.white, fontSize: 20.0))));
            }
            if (!snapshot.hasData) {
              return Container(
                  child: Center(
                      child: SizedBox(height: 40.0, width: 40.0,
                          child: CircularProgressIndicator(strokeWidth: 5,))));
            }

            if (snapshot.connectionState == ConnectionState.done)
            {
              if (widget.pageIndexInit == 1) {
                userListData.clear();
                userListData = snapshot.data;
              }
              else{
                newUserListData = snapshot.data;
                userListData = new List.from(userListData)..addAll(newUserListData); // page 처리 후 추가
              }

            }
            return dataEmptyCheck();
          },
        ),
      ],
    );
  }

  /// 등록된 유저 데이터 체크
  Widget dataEmptyCheck() {
    if (userListData.isEmpty) {
      return Center(
        child: Text('등록된 나의 내담자가 없습니다.', textScaleFactor: 0.96),
      );
    } else {
      return RefreshIndicator(
        key: refreshKey,
        onRefresh: () => _refreshList(),
        child: ListView.builder(
            controller: _scrollController,
            itemCount: userListData.length,
            padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 15.0),
            itemBuilder: (BuildContext context, int index)
            {
              return UserCardView( userListData[index], index % 2 == 0 ? userList_1 : Colors.white, widget.auth, widget.identification, senderName:userDetails.name);
            }),
      );
    }
  }


  ///User List Update
  Future<Null> _refreshList() async {
    setState(() {});
    return null;
  }

  _getSenderName() async{
    userDetails = await client.getUserDetails(widget.auth.userID, widget.auth.account);
    print('SENDER NAME::'+userDetails.name);
  }

}