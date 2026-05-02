import 'package:flutter/material.dart';
import '../model/kalender_model.dart';
import '../services/kalender_service.dart';

class HijriCalendarViewModel extends ChangeNotifier {
  DateTime _selectedGregorianDate = DateTime.now();
  late HijriDate _currentHijriDate;
  int _selectedMonth = 1;
  int _selectedYear = 1446;

  HijriCalendarViewModel() {
    _currentHijriDate =
        HijriCalendarService.gregorianToHijri(_selectedGregorianDate);
    _selectedMonth = _currentHijriDate.month;
    _selectedYear = _currentHijriDate.year;
  }

  // Getters
  DateTime get selectedGregorianDate => _selectedGregorianDate;
  HijriDate get currentHijriDate => _currentHijriDate;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  String get currentMonthName => HijriMonths.getName(_selectedMonth);
  String get currentMonthArabic =>
      HijriMonths.getArabicName(_selectedMonth);

  // Get events for current month
  List<IslamicEvent> get currentMonthEvents {
    return HijriCalendarService.getEventsForMonth(_selectedMonth);
  }

  // ✅ FIX: Get first day offset (tanpa hijriToGregorian)
  int getFirstDayOffset() {
  try {
    DateTime date = _selectedGregorianDate;

    for (int i = 0; i < 35; i++) {
      final hijri = HijriCalendarService.gregorianToHijri(date);

      if (hijri.day == 1 &&
          hijri.month == _selectedMonth &&
          hijri.year == _selectedYear) {
        int weekday = date.weekday % 7;

        return weekday;
      }

      date = date.subtract(const Duration(days: 1));
    }

    return 0;
  } catch (e) {
    return 0;
  }
}
  // Helper: Get day name
  // ignore: unused_element
  String _getDayName(int offset) {
    const days = [
      'Ahad',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    if (offset < 0 || offset > 6) return 'Unknown';
    return days[offset];
  }

  // Select a date
  void selectDate(DateTime date) {
    _selectedGregorianDate = date;
    _currentHijriDate =
        HijriCalendarService.gregorianToHijri(date);
    notifyListeners();
  }

  // Go to today
  void goToToday() {
    _selectedGregorianDate = DateTime.now();
    _currentHijriDate =
        HijriCalendarService.gregorianToHijri(_selectedGregorianDate);
    _selectedMonth = _currentHijriDate.month;
    _selectedYear = _currentHijriDate.year;
    notifyListeners();
  }

  // Change month
  void changeMonth(int month) {
    if (month >= 1 && month <= 12) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  // Next month
  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    notifyListeners();
  }

  // Previous month
  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    notifyListeners();
  }

  // Convert Gregorian → Hijri
  HijriDate convertToHijri(DateTime gregorian) {
    return HijriCalendarService.gregorianToHijri(gregorian);
  }

  // Get event
  IslamicEvent? getEventForDate(int day, int month) {
    return HijriCalendarService.getEventForDate(day, month);
  }

  // Days in month
  int get daysInCurrentMonth {
    return HijriCalendarService.getDaysInMonth(
        _selectedMonth, _selectedYear);
  }

  // Format Hijri
  String formatHijriDate(HijriDate date) {
    return '${date.day} ${date.monthName} ${date.year} H';
  }

  // Format Gregorian
  String formatGregorianDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}