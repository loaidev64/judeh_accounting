/// Extension on [DateTime] to add custom formatting methods.
extension NewDateTime on DateTime {
  /// Helper function to ensure two-digit formatting.
  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  /// Returns the day of the month as a string (e.g., "15").
  String get dayName => switch (weekday) {
        DateTime.monday => 'الاثنين',
        DateTime.tuesday => 'الثلاثاء',
        DateTime.wednesday => 'الاربعاء',
        DateTime.thursday => 'الخميس',
        DateTime.friday => 'الجمعة',
        DateTime.saturday => 'السبت',
        _ => 'الاحد',
      };

  /// Returns the date in the format "yyyy-MM-dd".
  String get toDateString => '$year-${_twoDigits(month)}-${_twoDigits(day)}';

  /// Returns the time in the format "HH:MM AM/PM".
  String get toTimeString {
    final hourFormat =
        hour > 12 ? hour - 12 : hour; // Convert to 12-hour format
    final period = hour >= 12 ? 'مساءاً' : 'صباحاً'; // Determine AM/PM
    return '${_twoDigits(hourFormat)}:${_twoDigits(minute)} $period';
  }

  /// Returns the date and time in the format "yyyy-MM-dd HH:mm:ss".
  ///
  /// Used for storing timestamps in the database.
  String get toFullString =>
      '$year-${_twoDigits(month)}-${_twoDigits(day)} ${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)}';

  static DateTime parseFromString(String date) {
    // Split the date and time parts
    final parts = date.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid date format');
    }

    // Split the date part into year, month, and day
    final dateParts = parts[0].split('-');
    if (dateParts.length != 3) {
      throw FormatException('Invalid date format');
    }

    // Split the time part into hour, minute, and second
    final timeParts = parts[1].split(':');
    if (timeParts.length != 3) {
      throw FormatException('Invalid time format');
    }

    // Parse the individual components
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]);

    // Create and return the DateTime object
    return DateTime(year, month, day, hour, minute, second);
  }
}
