import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://localhost:5000/api";
  // static const String baseUrl = "http://192.168.29.245:5000/api";

  static Future<Map<String, dynamic>?> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Signup error: $e");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Login error: $e");
    }

    return null;
  }

  static Future<List<dynamic>> fetchProducts(String undertone) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products?undertone=$undertone"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Fetch products error: $e");
    }

    return [];
  }

  static Future<bool> saveSkinData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/skindata"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Save skin data error: $e");
    }

    return false;
  }

  // ✅ ADD THIS INSIDE THE CLASS
  static Future<Map<String, dynamic>?> getSkinData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/skindata/$userId"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Get skin data error: $e");
    }

    return null;
  }
}