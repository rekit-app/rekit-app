import 'package:shared_preferences/shared_preferences.dart';
import '../storage_keys.dart';

Future<void> resetDiagnosis() async {
  final prefs = await SharedPreferences.getInstance();
  await Future.wait([
    prefs.remove(StorageKeys.diagnosisCode),
    prefs.remove(StorageKeys.stage),
    prefs.remove(StorageKeys.day),
  ]);
}

Future<void> advanceDay({required int increment}) async {
  final prefs = await SharedPreferences.getInstance();
  final current = prefs.getInt(StorageKeys.day) ?? 1;
  await prefs.setInt(StorageKeys.day, current + increment);
}
