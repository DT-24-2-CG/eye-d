/*
데이터 모델 정의

{
"Name": "jin_ramen_soon",
"Price": 5000,
"Promotion": "2+1",
}

 */
// product_data.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '/main.dart';

class ProductData {
  final String Name, Promotion, Price;

  ProductData({required this.Name, required this.Price, required this.Promotion});

  // 서버에서 받은 JSON을 ProductData 객체로 변환
  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      Name: json['Name'],
      Price: json['Price'],
      Promotion: json['Promotion'],
    );
  }
}

// 서버에 사진을 업로드하고 응답을 받는 함수
Future<ProductData?> fetchProductData(String id) async {
  final url = Uri.parse(address + '/ID=$id');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return ProductData.fromJson(jsonResponse); // ProductData 객체로 변환
  } else {
    throw Exception("Failed to fetch product data.");
  }
}

Future<String?> uploadImageAndGetId(String imagePath) async {
  final url = Uri.parse('$address/upload');
  final file = File(imagePath);

  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final Map<String, dynamic> jsonResponse = jsonDecode(respStr);

    if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
      return jsonResponse['data']['id'].toString(); // ID 반환
    } else {
      return null;
    }
  } else {
    throw Exception('Upload failed: ${response.statusCode}');
  }
}
