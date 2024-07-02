import 'package:intl/intl.dart';

class Common {
  static final String IMAGE_BASE_URL = 'http://106.251.70.71:50006/profile/';

  static String getFormatDate(String dateTime)
  {
    if(dateTime == null)  return '';

    String toDay = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return DateFormat('a hh:mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime)).replaceAll('PM', '오후').replaceAll('AM', '오전');
    /*
    if(dateTime.contains(toDay))
      return DateFormat('a hh:mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime)).replaceAll('PM', '오후').replaceAll('AM', '오전');
    else
      return DateFormat('MM월 dd일').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
    */
  }

  static String getCustomFormatDate(String dateTime, String format)
  {
    return DateFormat(format).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime)).replaceAll('PM', '오후').replaceAll('AM', '오전'); 
  }

  static String getGroupID(String userID, String peerID) {
    String groupID = '';

    if (userID.hashCode <= peerID.hashCode) {
      groupID = '$userID-$peerID';
    } else {
      groupID = '$peerID-$userID';
    }

    return groupID;
  }
}