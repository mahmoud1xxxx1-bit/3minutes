enum PlayerNameIssue {
  invalidLength,
  missingLetterOrNumber,
  unsupportedCharacters,
}

class PlayerNameRules {
  const PlayerNameRules._();

  static const int minLength = 3;
  static const int maxLength = 20;

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static PlayerNameIssue? issueFor(String value) {
    final normalized = normalize(value);

    if (normalized.length < minLength || normalized.length > maxLength) {
      return PlayerNameIssue.invalidLength;
    }

    if (!RegExp(r'[A-Za-z0-9\u0600-\u06FF]').hasMatch(normalized)) {
      return PlayerNameIssue.missingLetterOrNumber;
    }

    if (RegExp(r'[\u0000-\u001F\u007F]').hasMatch(normalized)) {
      return PlayerNameIssue.unsupportedCharacters;
    }

    return null;
  }

  static String validate(String value) {
    final normalized = normalize(value);
    final issue = issueFor(normalized);

    switch (issue) {
      case PlayerNameIssue.invalidLength:
        throw ArgumentError(
          'Player name must be between $minLength and $maxLength characters.',
        );
      case PlayerNameIssue.missingLetterOrNumber:
        throw ArgumentError('Player name must include at least one letter or number.');
      case PlayerNameIssue.unsupportedCharacters:
        throw ArgumentError('Player name contains unsupported characters.');
      case null:
        return normalized;
    }
  }
}
