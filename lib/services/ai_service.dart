import 'dart:async'; // For TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carbon_activity.dart';

class ApiService {
  // Set to your local network IP (no space after http://!)
  static const String _baseUrl = 'http://192.168.137.74:8000';

  Future<Map<String, dynamic>> analyzeActivities(
      List<CarbonActivity> activities,
      String location,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'activities': activities.map((a) => {
            'category': a.category,
            'co2': a.co2,
            'date': a.date.toIso8601String().substring(0, 10),
          }).toList(),
          'location': location,
        }),
      ).timeout(const Duration(seconds: 30)); // A reasonable timeout

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'API request failed: ${response.statusCode}',
          'recommendations': [
            'Check if the backend is reachable at $_baseUrl',
            'Inspect server logs for errors'
          ],
        };
      }
    } on TimeoutException {
      return {
        'error': '''
Connection timeout. Please check:
1️⃣ Backend server is running (Python server logs)
2️⃣ The IP ($_baseUrl) is correct
3️⃣ Both devices are on the same WiFi network
'''
      };
    } catch (e) {
      return {
        'error': 'Connection failed: ${e.toString()}',
        'recommendations': [
          'Check your internet connection',
          'Ensure the backend server is running',
          'Try again later'
        ]
      };
    }
  }
}
