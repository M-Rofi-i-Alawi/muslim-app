import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'prayer_time_service.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  // ─── KEYS ─────────────────────────────────────────────────────────────────
  static const _kDarkMode      = 'dark_mode';
  static const _kNotifImsak    = 'notif_imsak';
  static const _kNotifSubuh    = 'notif_subuh';
  static const _kNotifTerbit   = 'notif_terbit';  // ✅ BARU
  static const _kNotifDhuha    = 'notif_dhuha';
  static const _kNotifDzuhur   = 'notif_dzuhur';
  static const _kNotifAshar    = 'notif_ashar';
  static const _kNotifMaghrib  = 'notif_maghrib';
  static const _kNotifIsya     = 'notif_isya';
  static const _kQuranFontSize = 'quran_font_size';
  static const _kLanguage      = 'language';
  static const _kLastCity      = 'last_city';
  static const _kUseGPS        = 'use_gps';
  static const _kLastLat       = 'last_lat';
  static const _kLastLng       = 'last_lng';

  // ─── SERVICES ─────────────────────────────────────────────────────────────
  final _notif     = NotificationService();
  final _prayerSvc = PrayerTimeService();

  // ─── STATE ────────────────────────────────────────────────────────────────
  bool   _darkMode      = false;
  bool   _notifImsak    = false;
  bool   _notifSubuh    = false;
  bool   _notifTerbit   = false; // ✅ BARU
  bool   _notifDhuha    = false;
  bool   _notifDzuhur   = false;
  bool   _notifAshar    = false;
  bool   _notifMaghrib  = false;
  bool   _notifIsya     = false;
  double _quranFontSize = 24.0;
  String _language      = 'id';
  String? _lastCity;
  bool   _useGPS        = true;
  double _lastLat       = -6.9175;
  double _lastLng       = 107.6191;
  bool   _loaded        = false;

  Map<String, DateTime> _cachedJadwal = {};

  // ─── GETTERS ──────────────────────────────────────────────────────────────
  bool    get darkMode      => _darkMode;
  bool    get notifImsak    => _notifImsak;
  bool    get notifSubuh    => _notifSubuh;
  bool    get notifTerbit   => _notifTerbit; // ✅ BARU
  bool    get notifDhuha    => _notifDhuha;
  bool    get notifDzuhur   => _notifDzuhur;
  bool    get notifAshar    => _notifAshar;
  bool    get notifMaghrib  => _notifMaghrib;
  bool    get notifIsya     => _notifIsya;
  double  get quranFontSize => _quranFontSize;
  String  get language      => _language;
  String? get lastCity      => _lastCity;
  bool    get useGPS        => _useGPS;
  double  get lastLat       => _lastLat;
  double  get lastLng       => _lastLng;
  bool    get isLoaded      => _loaded;
  ThemeMode get themeMode   =>
      _darkMode ? ThemeMode.dark : ThemeMode.light;

  // ─── LOAD ─────────────────────────────────────────────────────────────────
  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();

    _darkMode     = p.getBool(_kDarkMode)      ?? false;
    _notifImsak   = p.getBool(_kNotifImsak)    ?? false;
    _notifSubuh   = p.getBool(_kNotifSubuh)    ?? false;
    _notifTerbit  = p.getBool(_kNotifTerbit)   ?? false; // ✅
    _notifDhuha   = p.getBool(_kNotifDhuha)    ?? false;
    _notifDzuhur  = p.getBool(_kNotifDzuhur)   ?? false;
    _notifAshar   = p.getBool(_kNotifAshar)    ?? false;
    _notifMaghrib = p.getBool(_kNotifMaghrib)  ?? false;
    _notifIsya    = p.getBool(_kNotifIsya)     ?? false;
    _quranFontSize = p.getDouble(_kQuranFontSize) ?? 24.0;
    _language     = p.getString(_kLanguage)    ?? 'id';
    _lastCity     = p.getString(_kLastCity);
    _useGPS       = p.getBool(_kUseGPS)        ?? true;
    _lastLat      = p.getDouble(_kLastLat)     ?? -6.9175;
    _lastLng      = p.getDouble(_kLastLng)     ?? 107.6191;
    _loaded       = true;

    notifyListeners();
    await _notif.init();

    // Jadwalkan notif yang aktif
    final anyActive = _notifImsak || _notifSubuh || _notifTerbit ||
        _notifDhuha || _notifDzuhur || _notifAshar ||
        _notifMaghrib || _notifIsya;
    if (anyActive) await refreshJadwal();
  }

  // ─── REFRESH JADWAL ───────────────────────────────────────────────────────
  Future<void> refreshJadwal() async {
    try {
      _cachedJadwal = await _prayerSvc.fetchJadwal(
        latitude:  _lastLat,
        longitude: _lastLng,
      );
      await _applyAllNotifications();
    } catch (e) {
      debugPrint('[SettingsService] Gagal refresh jadwal: $e');
    }
  }

  Future<void> _applyAllNotifications() async {
    if (_cachedJadwal.isEmpty) return;
    await _notif.scheduleAll(
      jadwalMap:  _cachedJadwal,
      enabledMap: _enabledMap(),
    );
  }

  Map<String, bool> _enabledMap() => {
    'imsak':   _notifImsak,
    'subuh':   _notifSubuh,
    'terbit':  _notifTerbit, // ✅
    'dhuha':   _notifDhuha,
    'dzuhur':  _notifDzuhur,
    'ashar':   _notifAshar,
    'maghrib': _notifMaghrib,
    'isya':    _notifIsya,
  };

  // ─── TOGGLE PER WAKTU ─────────────────────────────────────────────────────
  Future<void> setNotifWaktu(String waktu, bool value) async {
    final p = await SharedPreferences.getInstance();
    switch (waktu) {
      case 'imsak':   _notifImsak   = value; await p.setBool(_kNotifImsak,   value); break;
      case 'subuh':   _notifSubuh   = value; await p.setBool(_kNotifSubuh,   value); break;
      case 'terbit':  _notifTerbit  = value; await p.setBool(_kNotifTerbit,  value); break; // ✅
      case 'dhuha':   _notifDhuha   = value; await p.setBool(_kNotifDhuha,   value); break;
      case 'dzuhur':  _notifDzuhur  = value; await p.setBool(_kNotifDzuhur,  value); break;
      case 'ashar':   _notifAshar   = value; await p.setBool(_kNotifAshar,   value); break;
      case 'maghrib': _notifMaghrib = value; await p.setBool(_kNotifMaghrib, value); break;
      case 'isya':    _notifIsya    = value; await p.setBool(_kNotifIsya,    value); break;
    }
    notifyListeners();

    if (_cachedJadwal.containsKey(waktu)) {
      await _notif.scheduleWaktu(
        waktu:   waktu,
        jadwal:  _cachedJadwal[waktu]!,
        enabled: value,
      );
    } else if (value) {
      await refreshJadwal();
    }
  }

  // ─── SIMPAN LOKASI ────────────────────────────────────────────────────────
  Future<void> saveLocation({
    required double lat,
    required double lng,
    String? cityName,
  }) async {
    _lastLat  = lat;
    _lastLng  = lng;
    _lastCity = cityName;
    _useGPS   = cityName == null;
    notifyListeners();

    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kLastLat, lat);
    await p.setDouble(_kLastLng, lng);
    await p.setBool(_kUseGPS, _useGPS);
    if (cityName != null) {
      await p.setString(_kLastCity, cityName);
    } else {
      await p.remove(_kLastCity);
    }

    final anyActive = _notifImsak || _notifSubuh || _notifTerbit ||
        _notifDhuha || _notifDzuhur || _notifAshar ||
        _notifMaghrib || _notifIsya;
    if (anyActive) await refreshJadwal();
  }

  // ─── SETTER LAINNYA ───────────────────────────────────────────────────────
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDarkMode, value);
  }

  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size.clamp(18.0, 42.0);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kQuranFontSize, _quranFontSize);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLanguage, lang);
  }

  // ─── RESET ────────────────────────────────────────────────────────────────
  Future<void> resetAll() async {
    await _notif.cancelAll();
    final p = await SharedPreferences.getInstance();
    await p.clear();

    _darkMode     = false;
    _notifImsak   = false;
    _notifSubuh   = false;
    _notifTerbit  = false;
    _notifDhuha   = false;
    _notifDzuhur  = false;
    _notifAshar   = false;
    _notifMaghrib = false;
    _notifIsya    = false;
    _quranFontSize = 24.0;
    _language     = 'id';
    _lastCity     = null;
    _useGPS       = true;
    _lastLat      = -6.9175;
    _lastLng      = 107.6191;
    _cachedJadwal = {};

    notifyListeners();
  }
}