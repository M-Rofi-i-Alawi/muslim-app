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
import 'services/kalender_service.dart';
import 'services/zakat_calculator.dart';
import 'services/settings_service.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShalatViewModel(ShalatRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PanduanIbadahViewModel(PanduanIbadahRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => TasbihViewModel(),  // ← Tanpa parameter!
        ),
        ChangeNotifierProvider(
          create: (_) => ZakatViewModel(),  // ← Tanpa parameter!
        ),
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
        ChangeNotifierProvider(
          create: (_) => HijriCalendarViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => KiblatViewModel(KiblatRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => RamadhanViewModel(RamadhanRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(
            GeminiService('AIzaSyC8qeIgB1SDbji-dmA1u6kM7SRA0bwfHnQ'),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsService()..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF00A86B),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}