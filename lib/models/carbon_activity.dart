class CarbonActivity {
  String id;
  String category;
  String description;
  DateTime date;
  double co2;

  CarbonActivity({
    required this.id,
    required this.category,
    required this.description,
    required this.date,
    required this.co2,
  });

  CarbonActivity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        category = json['category'],
        description = json['description'] ?? '',
        co2 = (json['co2'] as num).toDouble(),
        date = DateTime.parse(json['date']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'description': description,
    'date': date.toIso8601String(),
    'co2': co2,
  };

  Map<String, dynamic> toMap() => toJson();
}
