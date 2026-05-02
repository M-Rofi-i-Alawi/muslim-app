// lib/services/notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const Map<String, int> _ids = {
    'imsak':   100,
    'subuh':   101,
    'terbit':  102, // ✅ BARU — batas akhir Subuh
    'dhuha':   103,
    'dzuhur':  104,
    'ashar':   105,
    'maghrib': 106,
    'isya':    107,
  };

  static const Map<String, String> _labels = {
    'imsak':   'Imsak',
    'subuh':   'Subuh',
    'terbit':  'Matahari Terbit',
    'dhuha':   'Dhuha',
    'dzuhur':  'Dzuhur',
    'ashar':   'Ashar',
    'maghrib': 'Maghrib',
    'isya':    'Isya',
  };

  static const Map<String, String> _bodies = {
    'imsak':   'Segera akhiri sahur, waktu imsak telah tiba.',
    'subuh':   'Waktunya shalat Subuh. Jangan lewatkan shalat pertama hari ini.',
    'terbit':  'Matahari telah terbit. Waktu shalat Subuh telah berakhir.',
    'dhuha':   'Waktu shalat Dhuha telah tiba. Sempurnakan ibadah pagi.',
    'dzuhur':  'Waktunya shalat Dzuhur. Istirahat sejenak, jangan tunda shalat.',
    'ashar':   'Waktunya shalat Ashar. Jaga shalat sebelum matahari terbenam.',
    'maghrib': 'Waktunya shalat Maghrib. Ucapkan syukur di penghujung siang.',
    'isya':    'Waktunya shalat Isya. Tutup hari dengan ibadah yang sempurna.',
  };

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final offset = DateTime.now().timeZoneOffset.inHours;
    final tzName = offset >= 9 ? 'Asia/Jayapura'
                 : offset >= 8 ? 'Asia/Makassar'
                 : 'Asia/Jakarta';
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
    debugPrint('[NotificationService] Init selesai. Zona: $tzName');
  }

  Future<void> scheduleWaktu({
    required String waktu,
    required DateTime jadwal,
    bool enabled = true,
  }) async {
    await init();
    final id = _ids[waktu];
    if (id == null) return;

    if (!enabled) {
      await _plugin.cancel(id);
      return;
    }

    if (jadwal.isBefore(DateTime.now())) {
      debugPrint('[NotificationService] $waktu sudah lewat, skip.');
      return;
    }

    final tzTime = tz.TZDateTime.from(jadwal, tz.local);
    final label  = _labels[waktu] ?? waktu;
    final body   = _bodies[waktu] ?? 'Waktunya $label.';

    await _plugin.zonedSchedule(
      id,
      'Waktu $label',
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'shalat_waktu_channel',
          'Pengingat Waktu Shalat',
          channelDescription: 'Notifikasi otomatis untuk setiap waktu shalat',
          importance: Importance.high,
          priority:   Priority.high,
          playSound:  true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('[NotificationService] Jadwal $waktu -> $tzTime');
  }

  Future<void> scheduleAll({
    required Map<String, DateTime> jadwalMap,
    required Map<String, bool> enabledMap,
  }) async {
    for (final entry in jadwalMap.entries) {
      await scheduleWaktu(
        waktu:   entry.key,
        jadwal:  entry.value,
        enabled: enabledMap[entry.key] ?? false,
      );
    }
  }

  Future<void> cancelWaktu(String waktu) async {
    final id = _ids[waktu];
    if (id != null) await _plugin.cancel(id);
  }

  Future<void> cancelAll() async => await _plugin.cancelAll();
}