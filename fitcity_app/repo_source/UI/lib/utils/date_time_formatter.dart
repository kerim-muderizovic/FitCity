class AppDateTimeFormat {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String date(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _months[local.month - 1];
    return '$day $month ${local.year}';
  }

  static String time(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String dateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return '${date(dateTime)}, ${time(dateTime)}';
  }

  static String range(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return '-';
    }
    if (start == null) {
      return dateTime(end);
    }
    if (end == null) {
      return dateTime(start);
    }
    final s = start.toLocal();
    final e = end.toLocal();
    if (s.year == e.year && s.month == e.month && s.day == e.day) {
      return '${date(s)}, ${time(s)}–${time(e)}';
    }
    return '${dateTime(s)}–${dateTime(e)}';
  }
}
