class PlayerNameRules {
  const PlayerNameRules._();

  static const int minLength = 3;
  static const int maxLength = 20;

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String validate(String value) {
    final normalized = normalize(value);

    if (normalized.length < minLength || normalized.length > maxLength) {
      throw ArgumentError(
        'Player name must be between $minLength and $maxLength characters.',
      );
    }

    if (!RegExp(r'[A-Za-z0-9\u0600-\u06FF]').hasMatch(normalized)) {
      throw ArgumentError('Player name must include at least one letter or number.');
    }

    if (RegExp(r'[\u0000-\u001F\u007F]').hasMatch(normalized)) {
      throw ArgumentError('Player name contains unsupported characters.');
    }

    return normalized;
  }
}
