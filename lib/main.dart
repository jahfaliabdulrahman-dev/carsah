import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/datasources/local/isar_provider.dart';
import 'data/models/vehicle.dart';
import 'presentation/pages/home/home_root_page.dart';
import 'presentation/pages/setup/welcome_page.dart';
import 'presentation/providers/settings_provider.dart';

/// ============================================================
/// Application Entry Point — CarSah
/// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final isar = await initIsarDatabase();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const CarSahApp(),
    ),
  );
}

const _brandBlue = Color(0xFF006064);

/// Root MaterialApp — routes to Welcome or Home based on vehicle count.
class CarSahApp extends ConsumerStatefulWidget {
  const CarSahApp({super.key});

  @override
  ConsumerState<CarSahApp> createState() => _CarSahAppState();
}

class _CarSahAppState extends ConsumerState<CarSahApp> {
  Widget? _home;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final isar = ref.read(isarProvider);
    final count = await isar.vehicles.count();
    if (mounted) {
      setState(() {
        _home = count == 0 ? const WelcomePage() : const HomeRootPage();
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Loading spinner while checking first-run state.
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'CarSah',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: settings.themeMode,

      // Pinned to English to prevent RTL visual corruption.
      locale: const Locale('en', ''),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: _home!,
    );
  }

  // — Themes ——

  static ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandBlue,
        brightness: Brightness.light,
      ).copyWith(surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      textTheme: GoogleFonts.cairoTextTheme(),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
      ),
      appBarTheme: const AppBarThemeData(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFF0F4F8),
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarThemeData(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
