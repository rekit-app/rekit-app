import 'dart:convert';

class WorkoutRecord {
  final DateTime completedAt;
  final String diagnosisCode;
  final int stage;
  final int day;

  const WorkoutRecord({
    required this.completedAt,
    required this.diagnosisCode,
    required this.stage,
    required this.day,
  });

  /// Unique key for deduplication: diagnosisCode + stage + day
  String get uniqueKey => '${diagnosisCode}_${stage}_$day';

  Map<String, dynamic> toJson() => {
        'completedAt': completedAt.toIso8601String(),
        'diagnosisCode': diagnosisCode,
        'stage': stage,
        'day': day,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
        completedAt: DateTime.parse(json['completedAt'] as String),
        diagnosisCode: json['diagnosisCode'] as String,
        stage: json['stage'] as int,
        day: json['day'] as int,
      );

  /// Relative day label (오늘 / 어제 / n일 전)
  String relativeDay(DateTime today) {
    final recordDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final diff = today.difference(recordDate).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return '$diff일 전';
  }

  /// Encode list to JSON string for SharedPreferences
  static String encodeList(List<WorkoutRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }

  /// Decode JSON string to list
  static List<WorkoutRecord> decodeList(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>)).toList();
  }
}
