import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final storage = FlutterSecureStorage();

  Future<String> getApiKey() async {
    return await storage.read(key: "GEMINI_API_KEY") ?? "";
  }

  Future<String> getSummary(String text) async {
    String apiKey = await getApiKey();

    if (apiKey.isEmpty) {
      throw Exception("❌ API Key is missing. Make sure it is stored securely.");
    }

    // ✅ Updated Gemini API Model Name
    final String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": text + " Give me summary of above text"}
            ]
          }
        ]
      }),
    );

    print("🔍 API Response: ${response.statusCode}");
    print("🔍 API Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          'No summary available.';
    } else {
      throw Exception("❌ Failed to fetch summary. Error: ${response.body}");
    }
  }
}
