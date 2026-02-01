import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage_keys.dart';
import 'screens/home_screen.dart';
import 'screens/paywall_screen.dart';

Future<void> _migrateLegacyKeys(SharedPreferences prefs) async {
  if (prefs.containsKey(StorageKeys.legacyDiagnosisCode)) {
    await prefs.setString(
      StorageKeys.diagnosisCode,
      prefs.getString(StorageKeys.legacyDiagnosisCode)!,
    );
    await prefs.remove(StorageKeys.legacyDiagnosisCode);
  }

  if (prefs.containsKey(StorageKeys.legacyDay)) {
    await prefs.setInt(StorageKeys.day, prefs.getInt(StorageKeys.legacyDay)!);
    await prefs.remove(StorageKeys.legacyDay);
  }

  if (prefs.containsKey(StorageKeys.legacyStage)) {
    await prefs.setInt(
      StorageKeys.stage,
      prefs.getInt(StorageKeys.legacyStage)!,
    );
    await prefs.remove(StorageKeys.legacyStage);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await _migrateLegacyKeys(prefs);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/paywall': (_) => const PaywallScreen(), // Sprint 2 등록
      },
      home: const HomeScreen(),
    );
  }
}
