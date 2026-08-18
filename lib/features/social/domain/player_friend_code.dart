class PlayerFriendCode {
  const PlayerFriendCode({
    required this.uid,
    required this.code,
  });

  final String uid;
  final String code;
}

class PlayerFriendCodePolicy {
  const PlayerFriendCodePolicy._();

  static final RegExp _valid = RegExp(r'^[A-Z0-9]{4,12}#[0-9]{4}$');

  static String normalizeNamePrefix(String value) {
    final normalized = value
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .trim();
    if (normalized.isEmpty) return 'PLAYER';
    final end = normalized.length > 12 ? 12 : normalized.length;
    return normalized.substring(0, end);
  }

  static String compose({
    required String name,
    required int suffix,
  }) {
    final safeSuffix = suffix.abs() % 10000;
    return '${normalizeNamePrefix(name)}#${safeSuffix.toString().padLeft(4, '0')}';
  }

  static bool isValid(String code) => _valid.hasMatch(code.trim().toUpperCase());
}
