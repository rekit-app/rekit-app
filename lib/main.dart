import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage_keys.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasDiagnosis = prefs.containsKey(StorageKeys.diagnosisCode);
  runApp(MyApp(hasDiagnosis: hasDiagnosis));
}

class MyApp extends StatelessWidget {
  final bool hasDiagnosis;

  const MyApp({super.key, required this.hasDiagnosis});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: hasDiagnosis ? const HomeScreen() : const IntroScreen(),
    );
  }
}
