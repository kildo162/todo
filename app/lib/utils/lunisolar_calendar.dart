import 'dart:math' as math;

class LunarDate {
  final int day;
  final int month;
  final int year;
  final bool isLeap;

  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    this.isLeap = false,
  });
}

class LunisolarConverter {
  static const int _timeZone = 7;

  static LunarDate solarToLunar(DateTime date) {
    final julianDay = _jdFromDate(date.day, date.month, date.year);
    final int k = ((julianDay - 2415021.076998695) / 29.530588853).floor();
    int monthStart = _getNewMoonDay(k + 1, _timeZone);

    if (monthStart > julianDay) {
      monthStart = _getNewMoonDay(k, _timeZone);
    }

    int a11 = _getLunarMonth11(date.year, _timeZone);
    int b11 = a11;
    int lunarYear;

    if (a11 >= monthStart) {
      lunarYear = date.year;
      a11 = _getLunarMonth11(date.year - 1, _timeZone);
    } else {
      lunarYear = date.year + 1;
      b11 = _getLunarMonth11(date.year + 1, _timeZone);
    }

    final int lunarDay = julianDay - monthStart + 1;
    final int diff = ((monthStart - a11) / 29).floor();
    int lunarMonth = diff + 11;

    int lunarLeap = 0;
    int leapMonth = 0;
    if (b11 - a11 > 365) {
      leapMonth = _getLeapMonthOffset(a11, _timeZone);
      if (diff >= leapMonth) {
        lunarMonth = diff + 10;
        if (diff == leapMonth) {
          lunarLeap = 1;
        }
      }
    }

    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }

    final bool isLeap = lunarLeap == 1;
    return LunarDate(day: lunarDay, month: lunarMonth, year: lunarYear, isLeap: isLeap);
  }

  static int _jdFromDate(int dd, int mm, int yy) {
    final int a = ((14 - mm) / 12).floor();
    final int y = yy + 4800 - a;
    final int m = mm + 12 * a - 3;
    return dd + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
  }

  static DateTime _jdToDate(int jd) {
    final int a = jd + 32044;
    final int b = ((4 * a + 3) / 146097).floor();
    final int c = a - ((b * 146097) / 4).floor();
    final int d = ((4 * c + 3) / 1461).floor();
    final int e = c - ((1461 * d) / 4).floor();
    final int m = ((5 * e + 2) / 153).floor();
    final int day = e - ((153 * m + 2) / 5).floor() + 1;
    final int month = m + 3 - 12 * (m / 10).floor();
    final int year = b * 100 + d - 4800 + (m / 10).floor();
    return DateTime(year, month, day);
  }

  static double _sunLongitude(double jdn) {
    final double t = (jdn - 2451545.0) / 36525;
    final double t2 = t * t;
    final double dr = math.pi / 180;
    final double m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final double l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    double dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(dr * m);
    dl = dl + (0.019993 - 0.000101 * t) * math.sin(dr * 2 * m) + 0.000290 * math.sin(dr * 3 * m);
    double l = l0 + dl;
    l = l * dr;
    l = l - math.pi * 2 * ((l / (math.pi * 2)).floor());
    return l;
  }

  static int _getSunLongitude(double dayNumber, int timeZone) {
    return (_sunLongitude(dayNumber - 0.5 - timeZone / 24) / math.pi * 6).floor();
  }

  static double _newMoon(int k) {
    final double t = k / 1236.85;
    final double t2 = t * t;
    final double t3 = t2 * t;
    final double dr = math.pi / 180;
    double jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 = jd1 + 0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);
    final double m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final double mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final double f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    double c1 = (0.1734 - 0.000393 * t) * math.sin(m * dr) + 0.0021 * math.sin(2 * dr * m);
    c1 = c1 - 0.4068 * math.sin(mpr * dr) + 0.0161 * math.sin(dr * 2 * mpr);
    c1 = c1 - 0.0004 * math.sin(dr * 3 * mpr);
    c1 = c1 + 0.0104 * math.sin(dr * 2 * f) - 0.0051 * math.sin(dr * (m + mpr));
    c1 = c1 - 0.0074 * math.sin(dr * (m - mpr)) + 0.0004 * math.sin(dr * (2 * f + m));
    c1 = c1 - 0.0004 * math.sin(dr * (2 * f - m)) - 0.0006 * math.sin(dr * (2 * f + mpr));
    c1 = c1 + 0.0010 * math.sin(dr * (2 * f - mpr)) + 0.0005 * math.sin(dr * (2 * mpr + m));
    double delta = 0.0;
    if (t < -11) {
      delta = 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3;
    } else {
      delta = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    return jd1 + c1 - delta;
  }

  static int _getNewMoonDay(int k, int timeZone) {
    return (_newMoon(k) + 0.5 + timeZone / 24).floor();
  }

  static int _getLunarMonth11(int yy, int timeZone) {
    final int off = _jdFromDate(31, 12, yy) - 2415021;
    final int k = (off / 29.530588853).floor();
    int nm = _getNewMoonDay(k, timeZone);
    final int sunLong = _getSunLongitude(nm, timeZone);
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  static int _getLeapMonthOffset(int a11, int timeZone) {
    final int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    int last = 0;
    int i = 1;
    int arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    do {
      last = arc;
      i++;
      arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    } while (arc != last && i < 14);
    return i - 1;
  }

  static DateTime lunarToSolar(LunarDate lunarDate) {
    final int a11 = _getLunarMonth11(lunarDate.year, _timeZone);
    final int b11 = _getLunarMonth11(lunarDate.year + 1, _timeZone);
    int off = lunarDate.month - 11;
    if (off < 0) {
      off += 12;
    }
    if (b11 - a11 > 365) {
      final int leapOff = _getLeapMonthOffset(a11, _timeZone);
      final int leapMonth = leapOff - 2;
      if (lunarDate.isLeap && lunarDate.month != leapMonth + 1) {
        throw ArgumentError('Invalid leap month in lunar date');
      } else if (lunarDate.isLeap || off >= leapOff) {
        off += 1;
      }
    }
    final int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    final int monthStart = _getNewMoonDay(k + off, _timeZone);
    return _jdToDate(monthStart + lunarDate.day - 1);
  }
}
