import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // ✅ new package
import '../models/carbon_activity.dart';
import '../services/carbon_service.dart';
import '../services/recommendation_service.dart';
import '../services/ai_service.dart';
import 'add_activity_screen.dart';
import 'ai_analysis_screen.dart';
import 'stats_screen.dart';
import 'eco_chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _trend;
  List<String> _recommendations = [];
  bool _isLoadingAI = false;

  Future<void> _analyzeFootprint(List<CarbonActivity> activities) async {
    setState(() {
      _isLoadingAI = true;
    });

    final apiService = ApiService();
    final response = await apiService.analyzeActivities(activities, 'urban');

    if (response.containsKey('error')) {
      _showErrorDialog(response['error']);
    } else {
      setState(() {
        _trend = response['trend'];
        _recommendations = List<String>.from(response['recommendations']);
      });
    }

    setState(() {
      _isLoadingAI = false;
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Analysis Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carbonService = Provider.of<CarbonService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoBot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Full AI Analysis Screen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIAnalysisScreen(
                    activities: carbonService.activities,
                    location: 'urban',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'View Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildTodaySummary(carbonService)
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0),
          _buildRecommendations(context),
          if (_isLoadingAI)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_trend != null || _recommendations.isNotEmpty)
            _buildAIAnalysisCard(),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: carbonService.activities.length,
            itemBuilder: (context, index) {
              final activity = carbonService.activities[index];
              return _buildActivityCard(activity, context)
                  .animate(delay: (100 * index).ms)
                  .fadeIn()
                  .slideX(begin: 0.1);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.green,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.directions_walk),
            label: 'Add Activity',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddActivityScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.chat_bubble),
            label: 'Eco Chatbot',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EcoChatbotScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(CarbonService service) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Today's Carbon Footprint",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: service.todayTotal / service.dailyGoal,
              backgroundColor: Colors.grey[300],
              color: service.todayTotal > service.dailyGoal
                  ? Colors.red
                  : Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              "${service.todayTotal.toStringAsFixed(2)} kg CO2 / ${service.dailyGoal} kg CO2",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final carbonService = Provider.of<CarbonService>(context);
    final recommendations = RecommendationService()
        .getDemoRecommendations(carbonService.activities);

    if (recommendations.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Recommendations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• $rec'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisCard() {
    final isDecreasing = _trend == 'decreasing';
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Analysis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_trend != null)
              Row(
                children: [
                  Icon(
                    isDecreasing ? Icons.trending_down : Icons.trending_up,
                    color: isDecreasing ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trend: ${isDecreasing ? 'Decreasing' : 'Increasing'}',
                    style: TextStyle(
                      color: isDecreasing ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            if (_recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._recommendations.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• $rec'),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(CarbonActivity activity, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(activity.description),
        subtitle: Text("${activity.co2.toStringAsFixed(2)} kg CO2"),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            Provider.of<CarbonService>(context, listen: false)
                .removeActivity(activity.id);
          },
        ),
      ),
    );
  }
}
