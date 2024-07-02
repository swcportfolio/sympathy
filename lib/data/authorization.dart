
class Authorization{
  String userID;
  String password;
  String account;
  String authorizationToken;
  String tokenFcm;
  String profileImg;

  Authorization(
      {this.userID,
      this.password,
      this.authorizationToken,
      this.tokenFcm,
      this.account,
      this.profileImg});

  clean(){
    String userID ='';
    String password ='';
    String account ='';
    String authorizationToken ='';
    String tokenFcm = '';
    String profileImg ='';
  }
}