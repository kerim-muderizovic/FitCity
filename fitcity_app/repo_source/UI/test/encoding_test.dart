import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bosnian ARB has no mojibake markers', () {
    final file = File('lib/l10n/app_bs.arb');
    final text = file.readAsStringSync();
    const markers = ['Ã', 'Ä', 'Å', 'â', '€', '™'];
    final found = markers.where((m) => text.contains(m)).toList();
    expect(found, isEmpty, reason: 'Found mojibake markers in app_bs.arb: $found');
  });
}
