import 'package:flutter/material.dart';
import 'screens/tutorial.dart';

final String address = 'http://172.21.91.3:5000';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // 앱 실행 시 TutorialScreen으로 시작
    );
  }
}

// 스플래시 화면
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3초 후 TutorialScreen으로 이동
    Future.delayed(Duration(seconds: 3), () {
      // 스플래시 화면에서 튜토리얼 화면으로 부드럽게 전환
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TutorialScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 페이드 전환 애니메이션
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    });

    return Scaffold(
      backgroundColor: Color(0xFF02457A), // 스플래시 화면 배경
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고나 이미지
            Image.asset(
              'assets/images/eye_d_logo.png', // 로고 이미지
              height: 120,
              width: 120,
            ),
            SizedBox(height: 20),
            // 로딩 텍스트
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
