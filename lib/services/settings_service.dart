import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan semua pengaturan aplikasi
/// menggunakan SharedPreferences agar persisten
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  // ─── KEY CONSTANTS ────────────────────────────────────────────────────────
  static const _kDarkMode          = 'dark_mode';
  static const _kNotifShalat       = 'notif_shalat';
  static const _kNotifSubuh        = 'notif_subuh';
  static const _kNotifDzuhur       = 'notif_dzuhur';
  static const _kNotifAshar        = 'notif_ashar';
  static const _kNotifMaghrib      = 'notif_maghrib';
  static const _kNotifIsya         = 'notif_isya';
  static const _kQuranFontSize     = 'quran_font_size';
  static const _kLanguage          = 'language'; // 'id' | 'en'
  static const _kFirstLaunch       = 'first_launch';

  // ─── STATE ────────────────────────────────────────────────────────────────
  bool   _darkMode      = false;
  bool   _notifShalat   = true;
  bool   _notifSubuh    = true;
  bool   _notifDzuhur   = true;
  bool   _notifAshar    = true;
  bool   _notifMaghrib  = true;
  bool   _notifIsya     = true;
  double _quranFontSize = 24.0;
  String _language      = 'id';
  bool   _loaded        = false;

  // ─── GETTERS ──────────────────────────────────────────────────────────────
  bool   get darkMode      => _darkMode;
  bool   get notifShalat   => _notifShalat;
  bool   get notifSubuh    => _notifSubuh;
  bool   get notifDzuhur   => _notifDzuhur;
  bool   get notifAshar    => _notifAshar;
  bool   get notifMaghrib  => _notifMaghrib;
  bool   get notifIsya     => _notifIsya;
  double get quranFontSize => _quranFontSize;
  String get language      => _language;
  bool   get isLoaded      => _loaded;

  ThemeMode get themeMode =>
      _darkMode ? ThemeMode.dark : ThemeMode.light;

  // ─── LOAD ─────────────────────────────────────────────────────────────────
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    _darkMode      = prefs.getBool(_kDarkMode)      ?? false;
    _notifShalat   = prefs.getBool(_kNotifShalat)   ?? true;
    _notifSubuh    = prefs.getBool(_kNotifSubuh)    ?? true;
    _notifDzuhur   = prefs.getBool(_kNotifDzuhur)   ?? true;
    _notifAshar    = prefs.getBool(_kNotifAshar)    ?? true;
    _notifMaghrib  = prefs.getBool(_kNotifMaghrib)  ?? true;
    _notifIsya     = prefs.getBool(_kNotifIsya)     ?? true;
    _quranFontSize = prefs.getDouble(_kQuranFontSize) ?? 24.0;
    _language      = prefs.getString(_kLanguage)    ?? 'id';
    _loaded        = true;

    notifyListeners();
  }

  // ─── SETTERS ──────────────────────────────────────────────────────────────
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> setNotifShalat(bool value) async {
    _notifShalat = value;
    // Jika matikan semua, matikan semua per-waktu juga
    if (!value) {
      _notifSubuh   = false;
      _notifDzuhur  = false;
      _notifAshar   = false;
      _notifMaghrib = false;
      _notifIsya    = false;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifShalat,  value);
    await prefs.setBool(_kNotifSubuh,   _notifSubuh);
    await prefs.setBool(_kNotifDzuhur,  _notifDzuhur);
    await prefs.setBool(_kNotifAshar,   _notifAshar);
    await prefs.setBool(_kNotifMaghrib, _notifMaghrib);
    await prefs.setBool(_kNotifIsya,    _notifIsya);
  }

  Future<void> setNotifWaktu(String waktu, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (waktu) {
      case 'subuh':
        _notifSubuh = value;
        await prefs.setBool(_kNotifSubuh, value);
        break;
      case 'dzuhur':
        _notifDzuhur = value;
        await prefs.setBool(_kNotifDzuhur, value);
        break;
      case 'ashar':
        _notifAshar = value;
        await prefs.setBool(_kNotifAshar, value);
        break;
      case 'maghrib':
        _notifMaghrib = value;
        await prefs.setBool(_kNotifMaghrib, value);
        break;
      case 'isya':
        _notifIsya = value;
        await prefs.setBool(_kNotifIsya, value);
        break;
    }
    // Update master toggle
    _notifShalat = _notifSubuh || _notifDzuhur ||
        _notifAshar || _notifMaghrib || _notifIsya;
    await prefs.setBool(_kNotifShalat, _notifShalat);
    notifyListeners();
  }

  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size.clamp(18.0, 42.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kQuranFontSize, _quranFontSize);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
  }

  // ─── RESET ────────────────────────────────────────────────────────────────
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _darkMode      = false;
    _notifShalat   = true;
    _notifSubuh    = true;
    _notifDzuhur   = true;
    _notifAshar    = true;
    _notifMaghrib  = true;
    _notifIsya     = true;
    _quranFontSize = 24.0;
    _language      = 'id';

    notifyListeners();
  }
}