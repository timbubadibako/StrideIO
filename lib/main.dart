import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'package:flutter_skill/flutter_skill.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterSkillBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('workouts');

  runApp(const ProviderScope(child: StrideIoApp()));
}

class StrideIoApp extends StatelessWidget {
  const StrideIoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrideIO',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
