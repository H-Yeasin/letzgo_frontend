import 'package:flutter_test/flutter_test.dart';
import 'package:letzgo_app/screens/auth/phone_input_screen.dart';

TextEditingValue format(String input) {
  return BdPhoneInputFormatter().formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: input),
  );
}

void main() {
  group('BdPhoneInputFormatter', () {
    test('keeps a plain 10-digit local number', () {
      expect(format('1645728080').text, '1645728080');
    });

    test('strips the leading 0 from a local-format number', () {
      expect(format('01645728080').text, '1645728080');
    });

    test('strips a pasted 880 country code', () {
      expect(format('8801645728080').text, '1645728080');
    });

    test('strips a pasted +880 country code with separators', () {
      expect(format('+880 1645-728080').text, '1645728080');
    });

    test('removes non-digit characters', () {
      expect(format('16457abc28080').text, '1645728080');
    });

    test('caps at 10 digits', () {
      expect(format('164572808099').text, '1645728080');
    });

    test('does not strip 880 from a partial local number', () {
      // While typing, short values starting with 880 must stay untouched
      expect(format('880').text, '880');
    });
  });
}
