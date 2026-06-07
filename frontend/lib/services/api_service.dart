import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.115.129:8000";

  static Future<List<String>> getLogs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/logs"),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data["logs"]);
      }

      return [];
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }
  static Future<List<dynamic>> getAlerts() async {
    final response =
    await http.get(Uri.parse("$baseUrl/alerts"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["alerts"];
    }

    return [];
  }
  static Future<Map<String, dynamic>> getStats() async {

    final response =
    await http.get(Uri.parse("$baseUrl/stats"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }
  static Future<Map<String, dynamic>> getSeverity() async {
    final response =
    await http.get(Uri.parse("$baseUrl/severity"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }
  static Future<List<dynamic>> getThreats() async {
    final response =
    await http.get(Uri.parse("$baseUrl/threats"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["threats"];
    }

    return [];
  }
  static Future<Map<String, dynamic>> scanUrl(String url) async {
    final response = await http.post(
      Uri.parse("$baseUrl/scan-url"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "url": url,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }

}