import 'package:flutter_test/flutter_test.dart';
import 'package:fitcity_flutter/utils/date_time_formatter.dart';

void main() {
  test('dateTime returns placeholder for null', () {
    expect(AppDateTimeFormat.dateTime(null), '-');
  });

  test('dateTime formats without raw tokens', () {
    final sample = DateTime.utc(2026, 2, 7, 9, 5);
    final formatted = AppDateTimeFormat.dateTime(sample);
    expect(formatted.contains('ddddd'), isFalse);
    expect(formatted.contains('dddd'), isFalse);
    expect(formatted, isNotEmpty);
  });
}
