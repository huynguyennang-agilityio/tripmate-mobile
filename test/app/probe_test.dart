// MF1-3 probe: a deliberately failing test. Never merge.
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MF1-3 probe: this test must fail', () {
    expect(1, 2);
  });
}
