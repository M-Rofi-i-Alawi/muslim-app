import 'package:flutter/material.dart';

class ShalatModel {
  final String tanggal;
  final String lokasi;   // Backward compatibility
  final String namaKota; // Nama kota dari GPS / pilihan user
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String imsak;
  final String terbit;
  final String dhuha;

  ShalatModel({
    required this.tanggal,
    required this.lokasi,
    required this.namaKota,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.imsak,
    required this.terbit,
    required this.dhuha,
  });

  factory ShalatModel.fromJson(
    Map<String, dynamic> json,
    String tanggal,
    String kota,
  ) {
    return ShalatModel(
      tanggal: tanggal,
      lokasi: kota,
      namaKota: kota,
      subuh: json['subuh'] ?? '00:00',
      dzuhur: json['dzuhur'] ?? '00:00',
      ashar: json['ashar'] ?? '00:00',
      maghrib: json['maghrib'] ?? '00:00',
      isya: json['isya'] ?? '00:00',
      imsak: json['imsak'] ?? '00:00',
      terbit: json['terbit'] ?? '00:00',
      dhuha: json['dhuha'] ?? '00:00',
    );
  }

  // ✅ FIX: Hapus "final now = DateTime.now();" — tidak dipakai → warning kuning hilang
  String getNextPrayer() {
    final currentTime = TimeOfDay.now();

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    bool isAfter(TimeOfDay time1, TimeOfDay time2) {
      if (time1.hour > time2.hour) return true;
      if (time1.hour < time2.hour) return false;
      return time1.minute > time2.minute;
    }

    final prayers = [
      {'name': 'Subuh',   'time': parseTime(subuh)},
      {'name': 'Dzuhur',  'time': parseTime(dzuhur)},
      {'name': 'Ashar',   'time': parseTime(ashar)},
      {'name': 'Maghrib', 'time': parseTime(maghrib)},
      {'name': 'Isya',    'time': parseTime(isya)},
    ];

    for (var prayer in prayers) {
      final prayerTime = prayer['time'] as TimeOfDay;
      if (!isAfter(currentTime, prayerTime)) {
        final timeStr = prayer['name'] == 'Subuh'
            ? subuh
            : prayer['name'] == 'Dzuhur'
                ? dzuhur
                : prayer['name'] == 'Ashar'
                    ? ashar
                    : prayer['name'] == 'Maghrib'
                        ? maghrib
                        : isya;
        return '${prayer['name']} - $timeStr';
      }
    }

    return 'Subuh - $subuh (Besok)';
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal':  tanggal,
      'lokasi':   lokasi,
      'namaKota': namaKota,
      'subuh':    subuh,
      'dzuhur':   dzuhur,
      'ashar':    ashar,
      'maghrib':  maghrib,
      'isya':     isya,
      'imsak':    imsak,
      'terbit':   terbit,
      'dhuha':    dhuha,
    };
  }
}