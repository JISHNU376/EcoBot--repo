import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/carbon_activity.dart';

class AIAnalysisScreen extends StatefulWidget {
  final List<CarbonActivity> activities;
  final String location;

  const AIAnalysisScreen({
    Key? key,
    required this.activities,
    this.location = 'urban',
  }) : super(key: key);

  @override
  _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  late Future<Map<String, dynamic>> _analysisFuture;
  final ApiService_aiService = ApiService();

  @override
  void initState() {
    super.initState();
    _analysisFuture = ApiService_aiService.analyzeActivities(widget.activities, widget.location);
  }

  void _refreshAnalysis() {
    setState(() {
      _analysisFuture = ApiService_aiService.analyzeActivities(widget.activities, widget.location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalysis,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return _buildErrorView(snapshot.data?['error'] ?? 'Unknown error');
          }

          final data = snapshot.data!;
          return _buildAnalysisView(data);
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(
            'Analysis Failed',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(error),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshAnalysis,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendCard(data['trend'], data['rate']?.toStringAsFixed(2)),
          const SizedBox(height: 20),
          _buildRecommendationsCard(data['recommendations']),
          if (data['analysis_date'] != null) ...[
            const SizedBox(height: 20),
            Text(
              'Analyzed on: ${data['analysis_date'].toString().substring(0, 10)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendCard(String trend, String? rate) {
    final isDecreasing = trend == 'decreasing';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TREND ANALYSIS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  isDecreasing ? Icons.trending_down : Icons.trending_up,
                  color: isDecreasing ? Colors.green : Colors.red,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Text(
                  isDecreasing ? 'Decreasing' : 'Increasing',
                  style: TextStyle(
                    fontSize: 24,
                    color: isDecreasing ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (rate != null) ...[
              const SizedBox(height: 10),
              Text(
                'Rate: ${rate} kg CO₂/day',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(List<dynamic> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RECOMMENDATIONS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rec.toString())),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}