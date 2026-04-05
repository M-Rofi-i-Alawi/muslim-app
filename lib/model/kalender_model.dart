class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final String dayName;

  HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.dayName,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      day: json['day'],
      month: json['month'],
      year: json['year'],
      monthName: json['monthName'],
      dayName: json['dayName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'monthName': monthName,
      'dayName': dayName,
    };
  }

  String get fullDate => '$day $monthName $year H';
  String get shortDate => '$day/$month/$year';
}

class IslamicEvent {
  final String name;
  final String description;
  final int day;
  final int month;
  final String category; // ramadan, eid, important, sunnah

  IslamicEvent({
    required this.name,
    required this.description,
    required this.day,
    required this.month,
    required this.category,
  });

  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      name: json['name'],
      description: json['description'],
      day: json['day'],
      month: json['month'],
      category: json['category'],
    );
  }
}

class HijriMonths {
  static const List<String> names = [
    'Muharram',
    'Safar',
    'Rabi\'ul Awwal',
    'Rabi\'ul Akhir',
    'Jumadal Ula',
    'Jumadal Akhirah',
    'Rajab',
    'Sya\'ban',
    'Ramadan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static const List<String> arabicNames = [
    'مُحَرَّم',
    'صَفَر',
    'رَبِيع ٱلْأَوَّل',
    'رَبِيع ٱلثَّانِي',
    'جُمَادَىٰ ٱلْأُولَىٰ',
    'جُمَادَىٰ ٱلثَّانِيَة',
    'رَجَب',
    'شَعْبَان',
    'رَمَضَان',
    'شَوَّال',
    'ذُو ٱلْقَعْدَة',
    'ذُو ٱلْحِجَّة',
  ];

  static String getName(int month) {
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  static String getArabicName(int month) {
    if (month < 1 || month > 12) return '';
    return arabicNames[month - 1];
  }
}

class HijriDays {
  static const List<String> names = [
    'Ahad',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  static String getName(int day) {
    if (day < 0 || day > 6) return '';
    return names[day];
  }
}