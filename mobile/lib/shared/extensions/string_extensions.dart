extension StringX on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String? get nullIfEmpty => trim().isEmpty ? null : this;
}
