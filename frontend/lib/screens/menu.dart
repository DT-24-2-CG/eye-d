import 'package:flutter/material.dart';
import 'dart:io'; // exit 함수
import 'tutorial.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';  // TTS

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late FlutterTts _flutterTts_menu;

  @override
  void initState() {
    super.initState();
    _flutterTts_menu = FlutterTts();  // FlutterTts 객체 초기화

    // 음성 출력 완료 후 호출되는 핸들러 설정
    _flutterTts_menu.setCompletionHandler(() {
      print("TTS 완료");
    });

    // 오류 처리 핸들러 설정
    _flutterTts_menu.setErrorHandler((msg) {
      print("TTS 오류: $msg");
    });

    _flutterTts_menu.setLanguage("ko-KR"); // 언어 설정
    _flutterTts_menu.setSpeechRate(0.5);
    _flutterTts_menu.setVolume(1.0);
    _flutterTts_menu.setPitch(1.0);         // 음성 톤 설정

    _speakText("메뉴 화면입니다");  // 화면 진입 시 TTS로 텍스트 읽기
  }

  // TTS로 텍스트를 말하는 함수
  Future<void> _speakText(String text) async {
    await _flutterTts_menu.stop();
    await _flutterTts_menu.speak(text);  // 전달된 텍스트를 음성으로 읽음
  }

  @override
  void dispose() {
    _flutterTts_menu.stop();  // TTS 정지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼을 눌렀을 떄 앱 종료
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App?'),
            content: Text('앱을 종료하겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // 앱 종료 취소
                child: Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('네'),
              ),
            ],
          ),
        );

        if (shouldExit) {
          exit(0);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Camera Button
              GestureDetector(
                onTap: () {
                  // 카메라 버튼 클릭 시 동작
                  print('Camera button tapped');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen()),
                  );
                },
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFC7064D), // 버튼 배경색
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 카메라 이미지
                      Image.asset(
                        'assets/images/camera.png', // 카메라 이미지 경로
                        height: 130,
                        width: 130,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Tutorial and History Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tutorial Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 튜토리얼 버튼 클릭 시 동작
                        print('Tutorial button tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TutorialScreen()),
                        );
                      },
                      child: Container(
                        height: 400,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 전구 이미지
                            Image.asset(
                              'assets/images/tutorial.png', // 전구 이미지 경로
                              height: 90,
                              width: 90,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tutorial',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // History Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 히스토리 버튼 클릭 시 동작
                        print('History button tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryScreen()),
                        );
                      },
                      child: Container(
                        height: 400,
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.lightGreenAccent,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 히스토리 이미지
                            Image.asset(
                              'assets/images/history.png', // 히스토리 이미지 경로
                              height: 90,
                              width: 90,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'History',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
