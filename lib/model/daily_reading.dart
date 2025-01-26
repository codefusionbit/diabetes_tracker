import 'package:diabetes_tracking/codefusionbit.dart';

// Model classes
class DailyReading {
  final String? id;
  final DateTime date;
  final num? fastingValue;
  final DateTime? fastingDate;
  final num? nonFastingValue;
  final DateTime? nonFastingDate;
  final List<FoodRecord> foodRecords;

  DailyReading({
    this.id,
    required this.date,
    this.fastingValue,
    this.fastingDate,
    this.nonFastingValue,
    this.nonFastingDate,
    this.foodRecords = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': Timestamp.fromDate(date),
    'fastingValue': fastingValue,
    'fastingDate':
    fastingDate != null ? Timestamp.fromDate(fastingDate!) : null,
    'nonFastingValue': nonFastingValue,
    'nonFastingDate':
    nonFastingDate != null ? Timestamp.fromDate(nonFastingDate!) : null,
    'foodRecords': foodRecords.map((record) => record.toJson()).toList(),
  };

  factory DailyReading.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyReading(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      fastingValue: data['fastingValue'],
      fastingDate: data['fastingDate'] != null
          ? (data['fastingDate'] as Timestamp).toDate()
          : null,
      nonFastingValue: data['nonFastingValue'],
      nonFastingDate: data['nonFastingDate'] != null
          ? (data['nonFastingDate'] as Timestamp).toDate()
          : null,
      foodRecords: (data['foodRecords'] as List<dynamic>?)
          ?.map((record) =>
          FoodRecord.fromJson(record as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}