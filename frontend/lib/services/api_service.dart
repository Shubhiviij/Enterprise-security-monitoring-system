import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.115.129:8000',
  );

  // ─────────────────────────────────────────────
  // AUTHENTICATION
  // ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return Map<String, dynamic>.from(data);
      }

      print("LOGIN FAILED: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Authentication connection error: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LIVE LOGS
  // ─────────────────────────────────────────────

  static Future<List<String>> getLogs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/logs"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return List<String>.from(data["logs"]);
      }

      print("GET LOGS FAILED: ${response.statusCode}");
      return [];
    } catch (e) {
      print("Logs connection error: $e");
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
  static Future<bool> updateAlertStatus(String alertId, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/alerts/update-status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "alert_id": alertId,
          "status": newStatus,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Failed to sync incident triage update status: $e");
      return false;
    }
  }
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createNewUser(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password, "role": role}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> changeUserRole(int id, String selectedRole) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/users/$id/role"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"role": selectedRole}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deprovisionUser(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/users/$id"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  static Future<Map<String, dynamic>> getBehaviorAnalysis() async {
    final response =
    await http.get(Uri.parse('$baseUrl/api/behavior-analysis'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to fetch behavioral analysis");
  }
  static Future<List<Map<String, dynamic>>> getBehaviorHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/behavior-history'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final history = data['history'];

        if (history is List) {
          return history
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      print(
        'Behavior history request failed: '
            '${response.statusCode} ${response.body}',
      );

      return [];
    } catch (e) {
      print('Behavior history error: $e');
      return [];
    }
  }
}