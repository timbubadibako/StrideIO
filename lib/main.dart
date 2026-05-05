import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'dev/dev_providers.dart';
import 'dev/dev_menu.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_skill/flutter_skill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  FlutterSkillBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('workouts');
  await Hive.openBox('sync_queue');
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const StrideIoApp(),
    ),
  );
}

class StrideIoApp extends StatelessWidget {
  const StrideIoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrideIO',
      theme: AppTheme.darkTheme,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const SplashScreen(),
      routes: (!kReleaseMode || kAllowDevMenuInRelease)
          ? {'/dev': (_) => const DevMenu()}
          : const {},
      debugShowCheckedModeBanner: false,
    );
  }
}
