import 'package:flutter/material.dart';
import 'package:sympathy_app/data/authorization.dart';
import 'package:sympathy_app/data/coach.dart';
import 'package:sympathy_app/utils/constants.dart';
import 'package:sympathy_app/utils/dio_client.dart';
import 'package:sympathy_app/widget/widget.dart';

class UserListPage extends StatefulWidget {

  final Authorization auth;
  final String name, dateOfBirth; // 내담자 검색 data
  final bool identification;      // 나의 내담자: true,  내담자 찾기: false
  final String status;            // N 일때 등록되지 않은 내담자 리스트
  final String requesterID;       // 상담사 ID
  final hopeTime1, hopeTime2;     // 상담시간 - 검색
  int pageIndexInit;

  UserListPage(this.auth, this.name, this.dateOfBirth, this.hopeTime1, this.hopeTime2, {this.identification, this.status, this.requesterID, this.pageIndexInit});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {

  List<UserListData> userListData    = [];
  List<UserListData> newUserListData = [];
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() { // page Scroll
      if(_scrollController.offset == _scrollController.position.maxScrollExtent){

        if(userListData.length % 10 == 0)
        {
          ++widget.pageIndexInit;
          print('====> user list pageCount :'+ widget.pageIndexInit.toString());
          _refreshList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('====> 검색 후 user list pageCount :'+ widget.pageIndexInit.toString());
    return Stack(
      children: [
        FutureBuilder(
          future: client.getUserDataList(page:widget.pageIndexInit, name:widget.name,
              dateOfBirth:widget.dateOfBirth, hopeTime1:widget.hopeTime1, hopeTime2:widget.hopeTime2, status:widget.status, requesterID:widget.requesterID),
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
            if (snapshot.connectionState == ConnectionState.done) {

              if (widget.pageIndexInit == 1) {
               // userListData.clear();
                userListData = snapshot.data;
              }else{
                newUserListData = snapshot.data;
                userListData = new List.from(userListData)..addAll(newUserListData); // page
              }

            }
            return dataEmptyCheck();
          },
        ),
      ],
    );
  }

  ///등록된 유저 데이터 체팅
  Widget dataEmptyCheck() {
    if (userListData.isEmpty) {
      return Center(
        child: Text('등록된 내담자가 없습니다.', textScaleFactor: 0.96),
      );
    } else {
      return ListView.builder(
          controller: _scrollController,
          itemCount: userListData.length,
          padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 15.0),
          itemBuilder: (BuildContext context, int index) {

            return UserCardView(userListData[index], index % 2 == 0 ? userList_1 : Colors.white, widget.auth, widget.identification );

          });
    }
  }

  /// User List Update
  Future<Null> _refreshList() async {
    setState(() {});
    return null;
  }

}