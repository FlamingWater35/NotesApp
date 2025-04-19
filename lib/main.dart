import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_screen.dart';
import 'components/update_service.dart';
import 'providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Might not be needed, added for theme mode saving
  _setupLogging();
  runApp(const ProviderScope(child: MyApp()));
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  static final _log = Logger('MyApp');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MyApp._log.info("Building MyApp widget");
    final themeMode = ref.watch(themeProvider);
    const seedColor = Colors.blueAccent;

    _runUpdateCleanup();

    // Predictive back transitions for Android
    // const pageTransitionsTheme = PageTransitionsTheme(
    //   builders: <TargetPlatform, PageTransitionsBuilder>{
    //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    //   },
    // );

    return MaterialApp(
      title: 'Notes App',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // pageTransitionsTheme: pageTransitionsTheme,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        // pageTransitionsTheme: pageTransitionsTheme,
      ),
      
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

Future<void> _runUpdateCleanup() async {
  MyApp._log.info("Running update file cleanup check...");
  await UpdateService.cleanUpUpdateFile();
}