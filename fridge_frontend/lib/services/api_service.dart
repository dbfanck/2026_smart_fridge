import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fridge_item.dart';
import '../models/home_models.dart';

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

  static Future<FridgeStatus?> getStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) return null;
      return FridgeStatus.fromJson(data.last);
    }
    throw Exception('냉장고 상태 불러오기 실패');
  }

  static Future<List<ExpiringItem>> getExpiringItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items/expiring'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ExpiringItem.fromJson(e)).toList();
    }
    throw Exception('유통기한 임박 항목 불러오기 실패');
  }

  static Future<List<RecentItem>> getRecentItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items/recent'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RecentItem.fromJson(e)).toList();
    }
    throw Exception('최근 활동 불러오기 실패');
  }
}
