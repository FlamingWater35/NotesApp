import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';
import 'components/update_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Might not be needed, added for theme mode saving
  _setupLogging();
  runApp(const MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL; // Configure level as needed
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('StackTrace: ${record.stackTrace}');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final _log = Logger('MyApp');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.system);
  static const String _themePrefsKey = 'app_theme_mode';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _runUpdateCleanup();
    _themeNotifier.addListener(_saveThemePreference);
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedThemeName = prefs.getString(_themePrefsKey);
      ThemeMode loadedMode = ThemeMode.system;

      if (savedThemeName != null) {
        loadedMode = ThemeMode.values.firstWhere(
          (e) => e.name == savedThemeName,
          orElse: () => ThemeMode.system
        );
        MyApp._log.info("Loaded theme preference: $loadedMode");
      } else {
        MyApp._log.info("No saved theme preference found, using system default.");
      }

      if (_themeNotifier.value != loadedMode) {
        _themeNotifier.value = loadedMode;
      }
    } catch (e, stackTrace) {
      MyApp._log.severe("Error loading theme preference", e, stackTrace);
    }
   }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String themeName = _themeNotifier.value.name;
      await prefs.setString(_themePrefsKey, themeName);
      MyApp._log.info("Saved theme preference: ${_themeNotifier.value}");
    } catch (e, stackTrace) {
      MyApp._log.severe("Error saving theme preference", e, stackTrace);
    }
  }

  Future<void> _runUpdateCleanup() async {
    MyApp._log.info("Running update file cleanup check...");
    await UpdateService.cleanUpUpdateFile();
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_saveThemePreference);
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyApp._log.info("Building MyApp widget");
    const seedColor = Colors.blueAccent;

    const pageTransitionsTheme = PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        // Predictive back transitions for Android
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        // Keep defaults for other platforms
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, currentMode, __) {
        MyApp._log.fine("Rebuilding MaterialApp with themeMode: $currentMode");
        return MaterialApp(
          title: 'Notes App',

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            pageTransitionsTheme: pageTransitionsTheme,
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            pageTransitionsTheme: pageTransitionsTheme,
          ),
          
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: MainScreen(themeNotifier: _themeNotifier),
        );
      }
    );
  }
}