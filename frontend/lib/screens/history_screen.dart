import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/main.dart';
import 'package:flutter_tts/flutter_tts.dart';  // TTS
import 'menu.dart';  // MenuScreen을 import

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyData = []; // 서버에서 받아온 데이터 리스트
  bool isLoading = true; // 데이터를 로딩 중인지 여부
  int currentPage = 1; // 현재 페이지 (history=1부터 시작)
  final PageController _pageController = PageController();

  FlutterTts flutterTts = FlutterTts(); // TTS 인스턴스 생성

  @override
  void initState() {
    super.initState();
    fetchHistory(currentPage); // 초기화 시 서버에서 ID 리스트를 가져옴
    _initializeTTS(); // TTS 초기화
  }

  // TTS 초기화 함수
  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("ko-KR"); // 한국어로 설정
    await flutterTts.setPitch(1); // 음성의 높낮이 설정 (기본값은 1)
  }

  // 상품 정보를 TTS로 출력하는 함수
  Future<void> speakProductInfo(int index) async {
    if (index >= 0 && index < historyData.length) {
      final data = historyData[index];
      final name = data['Name'] ?? '알 수 없는 이름';
      final price = data['Price'] ?? '알 수 없는 가격';
      final promotion = data['Promotion'] ?? '행사 없음';

      final message = "상품 이름: $name, 가격: $price, 행사: $promotion";

      await flutterTts.stop(); // 이전 음성 중단
      await flutterTts.speak(message); // 상품 정보 음성 출력
    }
  }

  // 서버에서 데이터를 순차적으로 가져오는 함수
  Future<void> fetchHistory(int page) async {
    if (page < 1) return;
    final url = Uri.parse('$address/history=$page');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            if (page == 1) {
              historyData.clear(); // 첫 페이지일 경우 기존 데이터를 초기화
            }
            historyData.add(data); // 받아온 데이터를 리스트에 추가
            isLoading = false;
          });
          if (page == currentPage) speakProductInfo(page - 1); // 첫 페이지 로드 후 상품 정보 출력
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to fetch history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching history: $e');
    }
  }

  // 이전 페이지로 이동하는 함수
  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      fetchHistory(currentPage);
    }
  }

  // 다음 페이지로 이동하는 함수
  void goToNextPage() {
    // 마지막 페이지에서 더 이상 데이터를 요청하지 않도록 처리
    if (historyData.isNotEmpty) {
      setState(() {
        currentPage++;
      });

      // 서버에서 데이터 요청 후, 데이터가 있으면 페이지 이동
      fetchHistory(currentPage).then((_) {
        // 데이터가 비어 있으면 currentPage를 감소시키고, 페이지 이동을 막음
        if (historyData.isEmpty) {
          setState(() {
            currentPage--; // 페이지를 이전으로 되돌림
          });
        } else {
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      });
    }
  }


  // 뒤로가기 버튼을 누르면 MenuScreen으로 이동
  void navigateToMenu() {
    flutterTts.stop(); // TTS 중지
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MenuScreen()),  // MenuScreen으로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: navigateToMenu,  // 뒤로가기 버튼 클릭 시 MenuScreen으로 이동
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
          : PageView.builder(
        controller: _pageController,
        itemCount: historyData.length, // 리스트의 길이에 따라 아이템 수 설정
        onPageChanged: (index) {
          currentPage = index + 1; // 페이지 변경 시 현재 페이지 업데이트
          speakProductInfo(index); // 페이지 변경 시 TTS 출력
        },
        itemBuilder: (context, index) {
          final data = historyData[index];
          final imageUrl = '$address/history_image=${index + 1}?timestamp=${DateTime.now().millisecondsSinceEpoch}'; // 캐싱 방지용 timestamp 추가

          return Stack( // Stack을 사용하여 자유로운 위치 조정
            children: [
              Positioned(
                top: 330, // 세로 위치 지정 (이미지 아래)
                left: 20,
                right: 20,
                child: Text(
                  data['Name'] ?? 'Unknown Name',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.blue, // 파란색 텍스트
                  ),
                ),
              ),
              Positioned(
                top: 410, // 세로 위치 지정 (이미지 아래)
                left: 20,
                right: 20,
                child: Text(
                  'Price: ${data['Price'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue, // 파란색 텍스트
                  ),
                ),
              ),
              Positioned(
                top: 450, // 세로 위치 지정 (이미지 아래)
                left: 20,
                right: 20,
                child: Text(
                  'Promotion: ${data['Promotion'] ?? 'None'}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue, // 파란색 텍스트
                  ),
                ),
              ),
              Positioned(
                top: 20, // 세로 위치 지정
                left: 20,
                right: 20,
                child: Image.network(
                  imageUrl, // 서버에서 받은 이미지 URL 사용
                  fit: BoxFit.cover,
                  width: double.infinity, // 이미지가 전체 너비를 채우도록
                  height: 300, // 이미지의 높이를 설정
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // 이미지 로딩 완료
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ); // 로딩 중일 때 표시
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '이미지를 불러오지 못했습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {}); // 상태를 갱신하여 재시도
                            },
                            child: Text('재시도'),
                          ),
                        ],
                      ),
                    ); // 오류 발생 시 표시
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Stack을 사용하여 버튼 위치 조정
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Stack(
        children: [
          // 왼쪽 버튼 (이전 페이지)
          Positioned(
            left: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: goToPreviousPage,
              child: Icon(Icons.arrow_left),
              tooltip: 'Previous Page',
            ),
          ),
          // 오른쪽 버튼 (다음 페이지)
          Positioned(
            right: 60,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: goToNextPage,
              child: Icon(Icons.arrow_right),
              tooltip: 'Next Page',
            ),
          ),
        ],
      ),
    );
  }
}
