// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'repository/doa_repository.dart';
import 'repository/shalat_repository.dart';
import 'repository/surat_repository.dart';
import 'repository/ayat_repository.dart';
import 'repository/kiblat_repository.dart';
import 'repository/hadist_repository.dart';
import 'repository/asmaul_husna_repository.dart';
import 'repository/dzikir_repository.dart';
import 'repository/panduan_ibadah_repository.dart';
import 'repository/ramadhan_repository.dart';

import 'view/splash_page.dart';

import 'services/gemini_service.dart';
import 'services/settings_service.dart';
import 'services/dzikir_local_service.dart';

import 'viewmodel/doa_viewmodel.dart';
import 'viewmodel/shalat_viewmodel.dart';
import 'viewmodel/surat_viewmodel.dart';
import 'viewmodel/ayat_viewmodel.dart';
import 'viewmodel/kiblat_viewmodel.dart';
import 'viewmodel/chat_viewmodel.dart';
import 'viewmodel/hadist_viewmodel.dart';
import 'viewmodel/asmaul_husna_viewmodel.dart';
import 'viewmodel/dzikir_viewmodel.dart';
import 'viewmodel/tasbih_viewmodel.dart';
import 'viewmodel/zakat_viewmodel.dart';
import 'viewmodel/kalender_viewmodel.dart';
import 'viewmodel/panduan_ibadahn_viewmodel.dart';
import 'viewmodel/ramadhan_viewmodel.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Load settings (juga inisialisasi notifikasi)
  await SettingsService().load();
  await DzikirLocalService().cleanupOldData();
  await dotenv.load(fileName: "assets/.env");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>(
          create: (_) => SettingsService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShalatViewModel(ShalatRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PanduanIbadahViewModel(PanduanIbadahRepository()),
        ),
        ChangeNotifierProvider(create: (_) => TasbihViewModel()),
        ChangeNotifierProvider(create: (_) => ZakatViewModel()),
        ChangeNotifierProvider(
          create: (_) => DoaViewModel(DoaRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => HadistViewModel(HadistRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AsmaulHusnaViewModel(AsmaulHusnaRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => DzikirViewModel(DzikirRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SuratViewModel(SuratRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AyatViewModel(AyatRepository()),
        ),
        ChangeNotifierProvider(create: (_) => HijriCalendarViewModel()),
        ChangeNotifierProvider(
          create: (_) => KiblatViewModel(KiblatRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => RamadhanViewModel(RamadhanRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(
            GeminiService(dotenv.env['GEMINI_API_KEY']!),
          ),
        ),
      ],
      child: Consumer<SettingsService>(
        builder: (_, settings, __) => _MuslimApp(settings: settings),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// ROOT APP
// ─────────────────────────────────────────────
class _MuslimApp extends StatelessWidget {
  final SettingsService settings;
  const _MuslimApp({required this.settings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim App',
      themeMode: settings.themeMode,
      theme:     _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const SplashPage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor:  const Color(0xFF00A086),
      brightness: brightness,
      primary:    const Color(0xFF00A086),
      secondary:  const Color(0xFFE8A020),
      surface:    isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onSurface:  isDark ? Colors.white : const Color(0xFF1A1A2E),
      // ignore: deprecated_member_use
      background: isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7),
    );

    return ThemeData(
      useMaterial3:  true,
      colorScheme:   colorScheme,
      brightness:    brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF2F4F7),

      appBarTheme: const AppBarTheme(
        centerTitle:     true,
        elevation:       0,
        backgroundColor: Color(0xFF007A68),
        foregroundColor: Colors.white,
        iconTheme:       IconThemeData(color: Colors.white),
        titleTextStyle:  TextStyle(
          color:      Colors.white,
          fontSize:   18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        color:     isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFF00A086) : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFF00A086).withOpacity(0.4) : null),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFF00A086) : null),
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor:   Color(0xFF00A086),
        thumbColor:         Color(0xFF00A086),
        inactiveTrackColor: Color(0xFFB2DFDB),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white12 : Colors.grey.shade200,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: isDark ? Colors.white70 : null,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF00A086), width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A086),
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge:  TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
        bodyMedium: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade700),
        bodySmall:  TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade500),
      ),
    );
  }
}