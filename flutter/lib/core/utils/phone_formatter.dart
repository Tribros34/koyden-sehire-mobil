/// Helpers for Turkish mobile phone numbers (`05XXXXXXXXX`).
class PhoneFormatter {
  static final _digitsOnly = RegExp(r'\D');

  /// Strips everything except digits.
  static String digitsOnly(String input) => input.replaceAll(_digitsOnly, '');

  /// Returns true if the input matches the canonical 05XXXXXXXXX format.
  static bool isValid(String input) {
    final digits = digitsOnly(input);
    return digits.length == 11 && digits.startsWith('05');
  }

  /// `05551234567` → `0555 123 45 67`
  static String pretty(String input) {
    final d = digitsOnly(input);
    if (d.length != 11) return input;
    return '${d.substring(0, 4)} ${d.substring(4, 7)} '
        '${d.substring(7, 9)} ${d.substring(9, 11)}';
  }

  /// `05551234567` → `0555***4567` (used in OTP screen).
  static String mask(String input) {
    final d = digitsOnly(input);
    if (d.length != 11) return input;
    return '${d.substring(0, 4)}***${d.substring(7, 11)}';
  }
}
