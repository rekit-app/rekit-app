import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage_keys.dart';

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

Future<void> advanceDay({required int increment}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(StorageKeys.day) ?? 1;
    await prefs.setInt(StorageKeys.day, current + increment);
  } catch (e) {
    debugPrint('storage error: $e');
  }
}
