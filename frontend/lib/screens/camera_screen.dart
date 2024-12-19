import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:frontend/widgets/product_data.dart'; // product_data.dart 파일을 import
import 'package:flutter_tts/flutter_tts.dart'; // TTS
import 'menu.dart'; // MenuScreen을 import

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription>? cameras; // 카메라 목록
  CameraController? controller; // 카메라 컨트롤러
  bool isCameraInitialized = false;
  bool isPhotoCaptured = false; // 사진이 캡쳐되었는지 여부
  XFile? picture; // 촬영된 사진을 저장할 변수
  ProductData? productData; // 서버에서 받은 ProductData 객체를 저장할 변수
  bool isUploading = false; // 업로드 진행 상태를 추적
  final FlutterTts _flutterTts = FlutterTts(); // TTS 객체 생성
  bool ifAnalyzeFailed = false; // 분석 실패 여부

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _initializeTTS();
  }

  // TTS 초기화 설정
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('ko-KR'); // 한국어로 설정
    await _flutterTts.setSpeechRate(0.5); // 속도 설정
    await _flutterTts.setPitch(1.0); // 음성 피치 설정
    await _speak("카메라 화면입니다"); // 화면 진입 시 텍스트 읽기
  }

  // TTS로 텍스트 읽기
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void initializeCamera() async {
    cameras = await availableCameras(); // 사용 가능한 카메라 목록 가져오기
    controller = CameraController(
      cameras![0], // 기본 카메라 선택 (후면)
      ResolutionPreset.high, // 해상도 설정
    );

    await controller!.initialize(); // 카메라 초기화
    setState(() {
      isCameraInitialized = true;
    });
  }

  // 촬영된 사진을 서버로 보내고 ID를 받아옴
  Future<void> handlePictureUpload(XFile picture) async {
    setState(() {
      isUploading = true; // 업로드 시작 시 로딩 화면 활성화
    });

    try {
      // 사진 업로드 후 서버로부터 ID 받기
      // 인식 실패 시 id = '0'
      final id = await uploadImageAndGetId(picture.path);
      if (id != null && id != '0') {
        // ID를 사용하여 추가적인 데이터를 요청
        final product = await fetchProductData(id);
        setState(() {
          productData = product;
          isUploading = false; // 업로드 후 로딩 화면 종료
          ifAnalyzeFailed = false;
        });

        // TTS로 제품 정보 읽기
        if (productData != null) {
          String productInfo =
              "상품 이름: ${productData!.Name}, 가격: ${productData!.Price}, 행사: ${productData!.Promotion ?? 'None'}";
          await _speak(productInfo); // 제품 정보 읽기
        }
      } else {
        setState(() {
          ifAnalyzeFailed = true;
          isUploading = false;
        });

        // 실패 메시지 출력 및 3초 후 MenuScreen으로 이동
        await _speak("인식을 실패하였습니다. 메뉴 화면으로 돌아갑니다.");
        await Future.delayed(Duration(seconds: 5));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        productData = null;
      });
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose(); // 카메라 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼을 눌렀을 때 MenuScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
        return false; // 기본 뒤로가기 동작 방지
      },
      child: GestureDetector(
        onTap: () async {
          // 화면을 터치하면 사진 촬영
          if (controller != null && controller!.value.isInitialized) {
            try {
              final capturedPicture = await controller!.takePicture();
              setState(() {
                picture = capturedPicture; // 촬영된 사진 저장
                isPhotoCaptured = true; // 사진 캡처 상태 변경
              });
              await handlePictureUpload(capturedPicture); // 사진을 서버로 전송
            } catch (e) {
              print('Error taking photo: $e');
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Camera'),
          ),
          body: isCameraInitialized
              ? Stack(
            children: [
              if (!isPhotoCaptured)
                CameraPreview(controller!), // 실시간 카메라 미리보기

              // 촬영된 사진을 화면에 띄우기 (로딩 중에도 표시)
              if (isPhotoCaptured && picture != null)
                Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width / 4,
                  right: MediaQuery.of(context).size.width / 4,
                  child: Image.file(
                    File(picture!.path),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 2,
                  ),
                ),

              Positioned(
                bottom: 200, // 로딩 표시의 위치를 위로 조정
                left: 20,
                right: 20,
                child: isUploading
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 최소 크기로 Column 크기 설정
                    children: [
                      CircularProgressIndicator(), // 로딩 표시
                      SizedBox(height: 10), // 로딩 표시와 글씨 사이의 간격
                      Text(
                        'Analyzing...', // '분석중...' 텍스트
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                )
                    : ifAnalyzeFailed
                    ? Center(
                  child: Text(
                    '인식 실패',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
                    : isPhotoCaptured && productData != null
                    ? Column(
                  children: [
                    Text(
                      '상품 이름: ${productData?.Name ?? 'N/A'}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    Text(
                      '가격: ${productData?.Price ?? 'N/A'}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    Text(
                      '행사: ${productData?.Promotion ?? 'N/A'}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                )
                    : SizedBox.shrink(),
              ),
            ],
          )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
