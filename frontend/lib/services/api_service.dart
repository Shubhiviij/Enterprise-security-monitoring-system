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

    print("Calling alerts API");

    final response =
    await http.get(Uri.parse("$baseUrl/alerts"));

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["alerts"];
    }

    return [];
  }
}