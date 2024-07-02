
class Satisfaction{
  List<String>question =[
    '상담이 전반적으로 만족스러우셨습니까?',
    '상담을 통해 자신을 이해하는데 도움이 되었습니까?',
    '상담사는 공감적이었습니까?'
  ];
  List<String>resilienceQuestion =[
   '나는 어떤 위기든 극복할 수 있을 것이라고 믿는다.',
   '나는 힘든 상황에 처해도 어떻게든 잘 해결할 것이라고 믿는다.',
   '나는 어떤 업무를 맡더라도 잘해낼 자신이 있다.',
   '나는 어떠한 상황에 대해서도 잘 대처할 수 있는 능력이 있다.',
   '나는 내 자신의 능력을 믿는다.',
   '나는 문제 해결을 위해서 다양한 방법을 계속해서 시도할 수 있다.',
   '나는 도전적이고 어려운 일도 자신있게 수행할 수 있다.',
   '나에게 새로운 일이 주어지더라도 충분히 잘할 수 있을 거라고 믿는다.'
  ];

  List<String> value=['-1', '-1', '-1'];
  List<String> answer=['불만족','보통','만족'];

  //Resilience
  List<String> resilienceValue = ['-1','-1','-1','-1','-1','-1','-1','-1']; // 8문항 추가
  List<String> resilienceAnswer =['전혀 아니다    ', '약간 그렇다', '웬만큼 그렇다', '상당히 그렇다 ', '아주 그렇다'];

  Map<String, dynamic> toMap(String userID, String requesterID, List<String> answer, List<String> resilienceAnswer) {
    Map<String, dynamic> toMap = {
      'userID'      : userID,
      'requesterID' : requesterID,
      'a1'          : (int.parse(answer[0])+1).toString(),
      'a2'          : (int.parse(answer[1])+1).toString(),
      'a3'          : (int.parse(answer[2])+1).toString(),

      'a4'          : (int.parse(resilienceAnswer[0])).toString(),
      'a5'          : (int.parse(resilienceAnswer[1])).toString(),
      'a6'          : (int.parse(resilienceAnswer[2])).toString(),
      'a7'          : (int.parse(resilienceAnswer[3])).toString(),

      'a8'          : (int.parse(resilienceAnswer[4])).toString(),
      'a9'          : (int.parse(resilienceAnswer[5])).toString(),
      'a10'         : (int.parse(resilienceAnswer[6])).toString(),
      'a11'         : (int.parse(resilienceAnswer[7])).toString(),

    };
    return toMap;
  }

}