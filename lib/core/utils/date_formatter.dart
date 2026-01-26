import 'package:intl/intl.dart';

/// Utilitaires de formatage des dates
class DateFormatter {
  /// Formateur pour date courte (DD/MM/YYYY)
  static final _dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');

  /// Formateur pour date et heure (DD/MM/YYYY HH:mm)
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  /// Formateur pour heure seule (HH:mm)
  static final _timeFormatter = DateFormat('HH:mm', 'fr_FR');

  /// Formateur pour date longue (15 mars 2026)
  static final _dateLongFormatter = DateFormat('d MMMM yyyy', 'fr_FR');

  /// Formateur pour date avec jour (lundi 15 mars 2026)
  static final _dateWithDayFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

  /// Formateur pour mois et année (mars 2026)
  static final _monthYearFormatter = DateFormat('MMMM yyyy', 'fr_FR');

  /// Formate une date au format DD/MM/YYYY
  /// Exemple: DateTime(2026, 3, 15) → "15/03/2026"
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Formate une date et heure au format DD/MM/YYYY HH:mm
  /// Exemple: DateTime(2026, 3, 15, 14, 30) → "15/03/2026 14:30"
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Formate une heure au format HH:mm
  /// Exemple: DateTime(2026, 3, 15, 9, 5) → "09:05"
  static String formatTime(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  /// Formate une date au format long (15 mars 2026)
  static String formatDateLong(DateTime date) {
    return _dateLongFormatter.format(date);
  }

  /// Formate une date avec le jour de la semaine (lundi 15 mars 2026)
  static String formatDateWithDay(DateTime date) {
    return _dateWithDayFormatter.format(date);
  }

  /// Formate mois et année (mars 2026)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Formate une heure depuis une string "HH:mm:ss"
  /// Exemple: "14:30:00" → "14:30"
  static String formatTimeFromString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  /// Parse une date depuis une string ISO (yyyy-MM-dd)
  /// Exemple: "2026-03-15" → DateTime(2026, 3, 15)
  static DateTime? parseIsoDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Parse une date depuis une string française (DD/MM/YYYY)
  /// Exemple: "15/03/2026" → DateTime(2026, 3, 15)
  static DateTime? parseFrenchDate(String dateStr) {
    try {
      return _dateFormatter.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Calcule le nombre de jours entre deux dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Vérifie si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifie si une date est dans le passé
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now) && !isToday(date);
  }

  /// Vérifie si une date est dans le futur
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now) && !isToday(date);
  }

  /// Retourne une date relative (aujourd'hui, hier, demain, etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference == -1) {
      return 'Hier';
    } else if (difference > 1 && difference <= 7) {
      return 'Dans $difference jours';
    } else if (difference < -1 && difference >= -7) {
      return 'Il y a ${-difference} jours';
    } else {
      return formatDate(date);
    }
  }

  /// Formate une durée en format lisible
  /// Exemple: Duration(hours: 2, minutes: 30) → "2h 30min"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}min';
    } else {
      return 'Moins d\'une minute';
    }
  }

  /// Formate une date au format ISO (yyyy-MM-dd)
  /// Exemple: DateTime(2026, 3, 15) → "2026-03-15"
  static String formatDateISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
