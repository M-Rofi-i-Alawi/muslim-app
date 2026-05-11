// lib/services/tr_service.dart
//
// Localization Service — membaca terjemahan dari assets/lang/en.json
// Penggantian Google Translate online → INSTAN, offline, tidak perlu API key.
//
// ─── CARA PAKAI (sama seperti sebelumnya) ────────────────────────
// 1. Widget Text   → TrText('Jadwal Shalat')
// 2. String param  → context.tr('Cari kota...')
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'settings_service.dart';

// ─── SERVICE ──────────────────────────────────────────────────────────────────
class TrService extends ChangeNotifier {
  static final TrService _instance = TrService._();
  factory TrService() => _instance;
  TrService._();

  // Map terjemahan: 'teks_indonesia' → 'english text'
  Map<String, String> _translations = {};
  bool _loaded = false;

  // ── Load JSON dari assets ──────────────────────────────────────────────────
  Future<void> loadCache() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/lang/en.json');
      final Map<String, dynamic> map = json.decode(raw);
      _translations = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      debugPrint('TrService: Gagal load en.json — $e');
    }
    _loaded = true;
  }

  // ── Translate satu string (sync, instan) ───────────────────────────────────
  String translate(String text, String targetLang) {
    if (targetLang == 'id' || text.trim().isEmpty) return text;
    return _translations[text] ?? text;
  }

  // ── Ambil dari cache — alias untuk kompatibilitas ──────────────────────────
  String getCached(String text, String targetLang) {
    return translate(text, targetLang);
  }

  // ── Notify semua listener (dipanggil saat bahasa berubah) ─────────────────
  void onLanguageChanged() {
    notifyListeners();
  }

  // ── Tidak lagi dibutuhkan, dibiarkan kosong agar tidak break kode lama ─────
  Future<void> clearCache() async {
    notifyListeners();
  }

  int get cacheSize => _translations.length;
}

// ─── EXTENSION ────────────────────────────────────────────────────────────────
extension TrExtension on BuildContext {
  /// Sync translate — langsung dari JSON, instan tanpa HTTP.
  String tr(String text) {
    try {
      final lang = watch<SettingsService>().language;
      if (lang == 'id') return text;
      watch<TrService>(); // reactive: rebuild saat bahasa berubah
      return TrService().translate(text, lang);
    } catch (_) {
      return text;
    }
  }

  bool get isEn {
    try {
      return watch<SettingsService>().language == 'en';
    } catch (_) {
      return false;
    }
  }
}

// ─── WIDGET TrText ────────────────────────────────────────────────────────────
// Auto-translate + auto-rebuild saat bahasa diganti.
// Tidak ada async, tidak ada HTTP — langsung dari JSON lokal.
class TrText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // watch SettingsService & TrService agar rebuild otomatis saat bahasa berubah
    final lang = context.watch<SettingsService>().language;
    context.watch<TrService>();
    final displayed = TrService().translate(text, lang);

    return Text(
      displayed,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}