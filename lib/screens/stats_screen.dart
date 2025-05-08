import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/carbon_activity.dart';
import '../services/carbon_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carbonService = Provider.of<CarbonService>(context);
    final categoryData = _groupByCategory(carbonService.activities);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCategoryChart(categoryData),
            const SizedBox(height: 20),
            _buildWeeklyTrends(carbonService.activities),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categoryData) {
    final List<PieChartSectionData> pieChartSections = [];
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];

    int colorIndex = 0;
    categoryData.forEach((category, value) {
      pieChartSections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: '${value.toStringAsFixed(1)}kg',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: pieChartSections,
          centerSpaceRadius: 40,
          sectionsSpace: 0,
        ),
      ),
    );
  }

  Widget _buildWeeklyTrends(List<CarbonActivity> activities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total footprint this week: ${_calculateWeeklyTotal(activities).toStringAsFixed(1)} kg CO2',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _groupByCategory(List<CarbonActivity> activities) {
    final Map<String, double> result = {};
    for (var activity in activities) {
      result.update(
        activity.category,
            (value) => value + activity.co2,
        ifAbsent: () => activity.co2,
      );
    }
    return result;
  }

  double _calculateWeeklyTotal(List<CarbonActivity> activities) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return activities
        .where((activity) => activity.date.isAfter(weekAgo))
        .fold(0.0, (sum, activity) => sum + activity.co2);
  }
}