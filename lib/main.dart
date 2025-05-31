import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

import 'main_screen.dart';
import 'components/update_service.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();
  _runUpdateCleanup();
  runApp(const ProviderScope(child: MyApp()));
}

void _setupLogging() {
  Logger.root.level = Level.ALL; // Configure level as needed
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
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

    // Predictive back transitions for Android
    // const pageTransitionsTheme = PageTransitionsTheme(
    //   builders: <TargetPlatform, PageTransitionsBuilder>{
    //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    //   },
    // );

    SnackBarThemeData buildSnackBarTheme(ColorScheme colorScheme) {
      return SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        actionTextColor: colorScheme.inversePrimary,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        elevation: 4.0,
      );
    }

    return MaterialApp(
      title: 'Notes',
      /* For title localization
      onGenerateTitle: (context) {
        final localizations = AppLocalizations.of(context);
        return localizations.appTitle;
      }, 
      */
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        snackBarTheme: buildSnackBarTheme(
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness:
                Brightness
                    .dark, // For light theme, snackbar usually uses dark background
          ),
        ),
        // pageTransitionsTheme: pageTransitionsTheme,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        snackBarTheme: buildSnackBarTheme(
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness:
                Brightness
                    .light, // For dark theme, snackbar usually uses light background
          ),
        ),
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
