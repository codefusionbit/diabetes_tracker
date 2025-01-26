import 'package:diabetes_tracking/codefusionbit.dart';

class FoodRecord {
  final String? id;
  final String food;
  final String meal;
  final DateTime createdAt;

  FoodRecord({
    this.id,
    required this.food,
    required this.meal,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'food': food,
    'meal': meal,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory FoodRecord.fromJson(Map<String, dynamic> json) => FoodRecord(
    food: json['food'] as String,
    meal: json['meal'] as String,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}