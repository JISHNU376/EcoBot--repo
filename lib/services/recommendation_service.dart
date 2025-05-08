import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carbon_activity.dart';

class RecommendationService {
  static const String _apiUrl = 'https://yourapi.com/recommendations';

  Future<List<String>> getRecommendations(List<CarbonActivity> activities) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'activities': activities.map((a) => a.toMap()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['recommendations']);
      }
      return [];
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }

  // For demo purposes when API is not available
  List<String> getDemoRecommendations(List<CarbonActivity> activities) {
    final highImpactActivities = activities.where((a) => a.co2 > 2).toList();
    if (highImpactActivities.isEmpty) return [];

    return [
      'Consider reducing ${highImpactActivities[0].category} activities',
      'Try biking instead of driving for short trips',
      'Meat-free days can reduce your food footprint',
    ];
  }
}