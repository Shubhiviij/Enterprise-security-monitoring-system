import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.115.129:8000";

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Auth connection crash: $e");
      return null;
    }
  }

  static Future<List<String>> getLogs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/logs"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data["logs"]);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/alerts"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["alerts"];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/stats"));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getSeverity() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/severity"));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<List<dynamic>> getThreats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/threats"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["threats"];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> scanUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/scan-url"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": url}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {};
    } catch (e) {
      return {};
    }
  }
}