import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fridge_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  static Future<List<FridgeItem>> getLayouts() async {
    final response = await http.get(Uri.parse('$baseUrl/layouts'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => FridgeItem.fromJson(e)).toList();
    }
    throw Exception('레이아웃 불러오기 실패');
  }

  static Future<FridgeItemDetail> getItemDetail(int itemId) async {
    final response = await http.get(Uri.parse('$baseUrl/layouts/$itemId'));
    if (response.statusCode == 200) {
      return FridgeItemDetail.fromJson(jsonDecode(response.body));
    }
    throw Exception('상세 정보 불러오기 실패');
  }
}
