enum ShareExpiry {
  fiveMinutes,
  thirtyMinutes,
  oneHour,
  sixHours,
  oneDay,
  sevenDays,
  thirtyDays,
  oneYear,
  never;

  Duration? get duration {
    switch (this) {
      case ShareExpiry.fiveMinutes:
        return const Duration(minutes: 5);
      case ShareExpiry.thirtyMinutes:
        return const Duration(minutes: 30);
      case ShareExpiry.oneHour:
        return const Duration(hours: 1);
      case ShareExpiry.sixHours:
        return const Duration(hours: 6);
      case ShareExpiry.oneDay:
        return const Duration(days: 1);
      case ShareExpiry.sevenDays:
        return const Duration(days: 7);
      case ShareExpiry.thirtyDays:
        return const Duration(days: 30);
      case ShareExpiry.oneYear:
        return const Duration(days: 365);
      case ShareExpiry.never:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ShareExpiry.fiveMinutes:
        return '5 minutes';
      case ShareExpiry.thirtyMinutes:
        return '30 minutes';
      case ShareExpiry.oneHour:
        return '1 hour';
      case ShareExpiry.sixHours:
        return '6 hours';
      case ShareExpiry.oneDay:
        return '24 hours';
      case ShareExpiry.sevenDays:
        return '7 days';
      case ShareExpiry.thirtyDays:
        return '30 days';
      case ShareExpiry.oneYear:
        return '1 year';
      case ShareExpiry.never:
        return 'Never';
    }
  }

  DateTime? calculateExpiry() {
    final duration = this.duration;

    if (duration == null) {
      return null;
    }

    return DateTime.now().add(duration);
  }
}