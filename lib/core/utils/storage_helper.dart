import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage_keys.dart';
import '../config/stage_config.dart';
import '../models/workout_record.dart';

/// Read-only: 현재 진행 상태 (diagnosisCode, day, stage) 한번에 읽기
Future<({String? diagnosisCode, int day, int stage})> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  return (
    diagnosisCode: prefs.getString(StorageKeys.diagnosisCode),
    day: prefs.getInt(StorageKeys.day) ?? 1,
    stage: prefs.getInt(StorageKeys.stage) ?? 1,
  );
}

Future<void> resetDiagnosis() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(StorageKeys.diagnosisCode),
      prefs.remove(StorageKeys.stage),
      prefs.remove(StorageKeys.day),
    ]);
  } catch (e) {
    debugPrint('storage error: $e');
  }
}

/// Day를 증가시키고, Stage1 마지막 day를 초과하면 Stage2로 전환
///
/// Returns:
/// - true: Stage2 진입 (Paywall 표시 필요)
/// - false: 일반 day 증가
Future<bool> advanceDay({int increment = 1}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final diagnosisCode = prefs.getString(StorageKeys.diagnosisCode);
    final currentDay = prefs.getInt(StorageKeys.day) ?? 1;
    final currentStage = prefs.getInt(StorageKeys.stage) ?? 1;

    final newDay = currentDay + increment;

    // Stage1에서 마지막 day 초과 여부 확인
    if (currentStage == 1 && diagnosisCode != null) {
      final maxDays = getStage1Days(diagnosisCode);

      if (newDay > maxDays) {
        // Stage2로 전환
        await prefs.setInt(StorageKeys.stage, 2);
        await prefs.setInt(StorageKeys.day, 1);
        return true; // Paywall 표시 필요
      }
    }

    // 일반 day 증가
    await prefs.setInt(StorageKeys.day, newDay);
    return false;
  } catch (e) {
    debugPrint('storage error: $e');
    return false;
  }
}

/// Save a workout record (deduplicate by diagnosisCode + stage + day)
///
/// If a record with the same (dx, stage, day) exists, do NOT save.
Future<void> saveWorkoutRecord(WorkoutRecord record) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(StorageKeys.workoutRecords) ?? '[]';
    final records = WorkoutRecord.decodeList(existingJson);

    // Check for duplicate by unique key
    final exists = records.any((r) => r.uniqueKey == record.uniqueKey);
    if (exists) {
      debugPrint('Workout record already exists: ${record.uniqueKey}');
      return;
    }

    // Insert at beginning (latest first)
    records.insert(0, record);
    await prefs.setString(StorageKeys.workoutRecords, WorkoutRecord.encodeList(records));
  } catch (e) {
    debugPrint('storage error: $e');
  }
}

/// Load all workout records (latest first)
Future<List<WorkoutRecord>> loadWorkoutRecords() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(StorageKeys.workoutRecords) ?? '[]';
    final records = WorkoutRecord.decodeList(json);
    // Guarantee latest-first order at storage level
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  } catch (e) {
    debugPrint('storage error: $e');
    return [];
  }
}
