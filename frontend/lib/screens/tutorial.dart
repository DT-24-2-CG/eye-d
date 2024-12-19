import 'package:flutter/material.dart';
import 'menu.dart';
import 'package:flutter_tts/flutter_tts.dart';  // TTS 패키지

// 각 단계의 설명 텍스트
String tutorial_explain_1 = "튜토리얼 화면입니다.";
String tutorial_explain_2 = "메뉴는 3개의 버튼으로 이루어져 있습니다. 윗부분에 카메라 버튼, 왼쪽 아래에 튜토리얼 버튼, 오른쪽 아래에 히스토리 버튼이 있습니다.";
String tutorial_explain_3 = "튜토리얼 버튼은 이 음성을 다시 재생합니다";
String tutorial_explain_4 = "카메라 버튼을 누르면 카메라를 실행합니다. 물건의 사진을 찍으면 물건에 대한 정보를 재생합니다. 그 후 화면을 아무데나 터치하면 메뉴 화면으로 갑니다. 물건 인식 실패 시 다시 카메라 화면으로 돌아갑니다.";
String tutorial_explain_5 = "히스토리 버튼을 누르면 지금까지 인식한 물건을 다시 들을 수 있습니다. 왼쪽 아래와 오른쪽 아래의 버튼으로 목록을 이동할 수 있습니다.";
String tutorial_explain_6 = "이제 자동으로 메뉴 화면으로 갑니다.";

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late FlutterTts _flutterTts;
  int _currentStep = 1;  // 현재 단계 추적 (1~6)

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();  // FlutterTts 객체 초기화
    _flutterTts.setCompletionHandler(_onTtsCompletion);  // TTS 완료 후 호출될 핸들러 설정
    _speakText(tutorial_explain_1);  // 첫 번째 텍스트를 TTS로 읽기
  }

  // TTS로 텍스트를 말하는 함수
  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);  // 전달된 텍스트를 음성으로 읽음
  }

  // TTS 완료 시 호출되는 함수
  void _onTtsCompletion() {
    // TTS가 끝나면 다음 단계로 넘어가기
    _nextStep();
  }

  // 현재 단계에 맞는 텍스트 출력 후, 다음 단계로 넘어가는 함수
  void _nextStep() {
    setState(() {
      if (_currentStep == 1) {
        _currentStep = 2;
        _speakText(tutorial_explain_2);  // 두 번째 텍스트 출력
      } else if (_currentStep == 2) {
        _currentStep = 3;
        _speakText(tutorial_explain_3);  // 세 번째 텍스트 출력
      } else if (_currentStep == 3) {
        _currentStep = 4;
        _speakText(tutorial_explain_4);  // 네 번째 텍스트 출력
      } else if (_currentStep == 4) {
        _currentStep = 5;
        _speakText(tutorial_explain_5);  // 다섯 번째 텍스트 출력
      } else if (_currentStep == 5) {
        _currentStep = 6;
        _speakText(tutorial_explain_6);  // 여섯 번째 텍스트 출력
      } else if (_currentStep == 6) {
        // 마지막 단계에 도달하면 화면을 터치하면 메뉴 화면으로 넘어갑니다.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // _flutterTts.stop();  // TTS 정지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기를 누르면 앱 종료 대신 MenuScreen으로 이동하고 소리 멈추기
        await _flutterTts.stop(); // TTS 정지
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
        return false; // 뒤로 가기 기본 동작 차단
      },
      child: GestureDetector(
        onTap: _nextStep,  // 화면을 터치하면 다음 단계로 넘어가도록 설정
        child: Scaffold(
          backgroundColor: Colors.white, // 배경색 흰색으로 설정
          appBar: AppBar(
            title: Text('Tutorial'),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tutorial Start',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  'assets/images/headphone.png', // 이미지 경로 확인
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Explain\nhow to use\nthis app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
