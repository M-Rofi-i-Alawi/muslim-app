import '../model/kalender_model.dart';

class HijriCalendarService {
  // Convert Gregorian to Hijri using simplified algorithm
  static HijriDate gregorianToHijri(DateTime gregorian) {
    // Simplified conversion formula
    int year = gregorian.year;
    int month = gregorian.month;
    int day = gregorian.day;
    
    // Calculate Julian Day Number
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    
    int jdn = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    
    // Convert JDN to Hijri
    int l = jdn - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    
    int hijriMonth = (24 * l) ~/ 709;
    int hijriDay = l - ((709 * hijriMonth) ~/ 24);
    int hijriYear = 30 * n + j - 30;
    
    // Get day of week
    int dayOfWeek = gregorian.weekday % 7;
    
    return HijriDate(
      day: hijriDay,
      month: hijriMonth,
      year: hijriYear,
      monthName: HijriMonths.getName(hijriMonth),
      dayName: HijriDays.getName(dayOfWeek),
    );
  }

  // Get Islamic events for a specific Hijri month
  static List<IslamicEvent> getEventsForMonth(int month) {
    final allEvents = _getAllEvents();
    return allEvents.where((event) => event.month == month).toList();
  }

  // Get all Islamic events
  static List<IslamicEvent> _getAllEvents() {
    return [
      // Muharram (1)
      IslamicEvent(
        name: 'Tahun Baru Hijriah',
        description: '1 Muharram - Awal tahun baru Islam',
        day: 1,
        month: 1,
        category: 'important',
      ),
      IslamicEvent(
        name: 'Hari Asyura',
        description: '10 Muharram - Dianjurkan puasa',
        day: 10,
        month: 1,
        category: 'sunnah',
      ),
      
      // Rabi'ul Awwal (3)
      IslamicEvent(
        name: 'Maulid Nabi Muhammad SAW',
        description: '12 Rabi\'ul Awwal - Kelahiran Rasulullah',
        day: 12,
        month: 3,
        category: 'important',
      ),
      
      // Rajab (7)
      IslamicEvent(
        name: 'Isra Mi\'raj',
        description: '27 Rajab - Perjalanan malam Nabi',
        day: 27,
        month: 7,
        category: 'important',
      ),
      
      // Sya'ban (8)
      IslamicEvent(
        name: 'Nisfu Sya\'ban',
        description: '15 Sya\'ban - Malam pertengahan Sya\'ban',
        day: 15,
        month: 8,
        category: 'sunnah',
      ),
      
      // Ramadan (9)
      IslamicEvent(
        name: 'Awal Ramadan',
        description: '1 Ramadan - Bulan puasa dimulai',
        day: 1,
        month: 9,
        category: 'ramadan',
      ),
      IslamicEvent(
        name: 'Nuzulul Quran',
        description: '17 Ramadan - Turunnya Al-Quran',
        day: 17,
        month: 9,
        category: 'important',
      ),
      IslamicEvent(
        name: 'Lailatul Qadr (perkiraan)',
        description: '27 Ramadan - Malam seribu bulan',
        day: 27,
        month: 9,
        category: 'ramadan',
      ),
      
      // Syawwal (10)
      IslamicEvent(
        name: 'Idul Fitri',
        description: '1 Syawwal - Hari Raya Idul Fitri',
        day: 1,
        month: 10,
        category: 'eid',
      ),
      
      // Dzulhijjah (12)
      IslamicEvent(
        name: 'Hari Arafah',
        description: '9 Dzulhijjah - Wukuf di Arafah',
        day: 9,
        month: 12,
        category: 'important',
      ),
      IslamicEvent(
        name: 'Idul Adha',
        description: '10 Dzulhijjah - Hari Raya Idul Adha',
        day: 10,
        month: 12,
        category: 'eid',
      ),
      IslamicEvent(
        name: 'Hari Tasyriq',
        description: '11-13 Dzulhijjah - Hari penyembelihan',
        day: 11,
        month: 12,
        category: 'important',
      ),
    ];
  }

  // Check if a date has an event
  static IslamicEvent? getEventForDate(int day, int month) {
    final events = _getAllEvents();
    try {
      return events.firstWhere(
        (event) => event.day == day && event.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  // Get days in Hijri month (either 29 or 30)
  static int getDaysInMonth(int month, int year) {
    // Simplified: odd months have 30 days, even have 29
    // Last month (12) has 30 days in leap years
    if (month == 12) {
      return isLeapYear(year) ? 30 : 29;
    }
    return month.isOdd ? 30 : 29;
  }

  // Check if Hijri year is leap year
  static bool isLeapYear(int year) {
    // 11 leap years in every 30-year cycle
    return (year * 11 + 14) % 30 < 11;
  }
}