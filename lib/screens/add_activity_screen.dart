import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/carbon_service.dart';
import '../models/carbon_activity.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  String _selectedCategory = 'transport';
  String _selectedTransport = 'car';
  String _selectedFood = 'vegetables';
  String _selectedEnergyType = 'electricity';
  double _distance = 0;
  double _quantity = 0;
  double _energyUsage = 0;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category:'),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>['transport', 'food', 'energy']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildCategoryFields(),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveActivity,
                child: const Text('Save Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFields() {
    switch (_selectedCategory) {
      case 'transport':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transport Type:'),
            DropdownButton<String>(
              value: _selectedTransport,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTransport = newValue!;
                });
              },
              items: <String>['car', 'bus', 'train', 'plane', 'bike', 'walk']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('Distance (km):'),
            Slider(
              value: _distance,
              min: 0,
              max: 1000,
              divisions: 100,
              label: _distance.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _distance = value;
                });
              },
            ),
            Text('Selected: ${_distance.toStringAsFixed(1)} km'),
          ],
        );
      case 'food':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Food Type:'),
            DropdownButton<String>(
              value: _selectedFood,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFood = newValue!;
                });
              },
              items: <String>[
                'beef',
                'chicken',
                'pork',
                'fish',
                'vegetables',
                'fruits'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('Quantity (kg):'),
            Slider(
              value: _quantity,
              min: 0,
              max: 10,
              divisions: 100,
              label: _quantity.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _quantity = value;
                });
              },
            ),
            Text('Selected: ${_quantity.toStringAsFixed(2)} kg'),
          ],
        );
      case 'energy':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Energy Type:'),
            DropdownButton<String>(
              value: _selectedEnergyType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEnergyType = newValue!;
                });
              },
              items: <String>['electricity', 'natural_gas', 'heating_oil']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('Usage (kWh for electricity, therms for gas):'),
            Slider(
              value: _energyUsage,
              min: 0,
              max: 100,
              divisions: 100,
              label: _energyUsage.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _energyUsage = value;
                });
              },
            ),
            Text('Selected: ${_energyUsage.toStringAsFixed(1)}'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _saveActivity() {
    final carbonService = Provider.of<CarbonService>(context, listen: false);
    double co2 = 0;

    switch (_selectedCategory) {
      case 'transport':
        co2 = carbonService.calculateTransportFootprint(
            _distance, _selectedTransport);
        break;
      case 'food':
        co2 = carbonService.calculateFoodFootprint(_selectedFood, _quantity);
        break;
      case 'energy':
        co2 = _calculateEnergyFootprint(_selectedEnergyType, _energyUsage);
        break;
    }

    final activity = CarbonActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      description: _descriptionController.text.isEmpty
          ? _generateDefaultDescription()
          : _descriptionController.text,
      date: DateTime.now(),
      co2: co2,
    );

    carbonService.addActivity(activity);
    Navigator.pop(context);
  }

  String _generateDefaultDescription() {
    switch (_selectedCategory) {
      case 'transport':
        return '${_distance.toStringAsFixed(1)} km by $_selectedTransport';
      case 'food':
        return '${_quantity.toStringAsFixed(2)} kg of $_selectedFood';
      case 'energy':
        return '${_energyUsage.toStringAsFixed(1)} units of $_selectedEnergyType';
      default:
        return 'Activity';
    }
  }

  double _calculateEnergyFootprint(String energyType, double usage) {
    const Map<String, double> emissionFactors = {
      'electricity': 0.4, // kg CO2 per kWh (US average)
      'natural_gas': 5.3, // kg CO2 per therm
      'heating_oil': 10.1, // kg CO2 per gallon
    };
    return usage * (emissionFactors[energyType] ?? 0.0);
  }
}
