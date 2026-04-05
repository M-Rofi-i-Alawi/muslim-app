import 'package:flutter/material.dart';
import '../model/kalender_model.dart';
import '../services/kalender_service.dart';

class HijriCalendarViewModel extends ChangeNotifier {
  DateTime _selectedGregorianDate = DateTime.now();
  late HijriDate _currentHijriDate;
  int _selectedMonth = 1;
  int _selectedYear = 1446;

  HijriCalendarViewModel() {
    _currentHijriDate = HijriCalendarService.gregorianToHijri(_selectedGregorianDate);
    _selectedMonth = _currentHijriDate.month;
    _selectedYear = _currentHijriDate.year;
  }

  // Getters
  DateTime get selectedGregorianDate => _selectedGregorianDate;
  HijriDate get currentHijriDate => _currentHijriDate;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  String get currentMonthName => HijriMonths.getName(_selectedMonth);
  String get currentMonthArabic => HijriMonths.getArabicName(_selectedMonth);

  // Get events for current month
  List<IslamicEvent> get currentMonthEvents {
    return HijriCalendarService.getEventsForMonth(_selectedMonth);
  }

  // Select a date
  void selectDate(DateTime date) {
    _selectedGregorianDate = date;
    _currentHijriDate = HijriCalendarService.gregorianToHijri(date);
    notifyListeners();
  }

  // Navigate to today
  void goToToday() {
    _selectedGregorianDate = DateTime.now();
    _currentHijriDate = HijriCalendarService.gregorianToHijri(_selectedGregorianDate);
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

  // Get Hijri date for a specific Gregorian date
  HijriDate convertToHijri(DateTime gregorian) {
    return HijriCalendarService.gregorianToHijri(gregorian);
  }

  // Check if date has event
  IslamicEvent? getEventForDate(int day, int month) {
    return HijriCalendarService.getEventForDate(day, month);
  }

  // Get days in current month
  int get daysInCurrentMonth {
    return HijriCalendarService.getDaysInMonth(_selectedMonth, _selectedYear);
  }

  // Format Hijri date
  String formatHijriDate(HijriDate date) {
    return '${date.day} ${date.monthName} ${date.year} H';
  }

  // Format Gregorian date
  String formatGregorianDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Oct', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}