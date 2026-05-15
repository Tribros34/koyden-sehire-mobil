/// Locale-aware Turkish helpers (correct dotted/dotless I behaviour).
class TurkishChars {
  static const _upperMap = {
    'i': 'İ',
    'ı': 'I',
    'ş': 'Ş',
    'ğ': 'Ğ',
    'ü': 'Ü',
    'ö': 'Ö',
    'ç': 'Ç',
  };

  static const _lowerMap = {
    'İ': 'i',
    'I': 'ı',
    'Ş': 'ş',
    'Ğ': 'ğ',
    'Ü': 'ü',
    'Ö': 'ö',
    'Ç': 'ç',
  };

  static String toUpper(String input) {
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      buf.write(_upperMap[ch] ?? ch.toUpperCase());
    }
    return buf.toString();
  }

  static String toLower(String input) {
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      buf.write(_lowerMap[ch] ?? ch.toLowerCase());
    }
    return buf.toString();
  }
}
