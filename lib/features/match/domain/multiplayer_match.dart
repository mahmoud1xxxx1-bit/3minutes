import 'match_progress.dart';

enum MatchMode {
  ranked,
  quick,
  privateRoom,
  party;
}

enum ParticipantConnectionState {
  connected,
  reconnecting,
  disconnected,
}

class MatchParticipant {
  const MatchParticipant({
    required this.uid,
    required this.displayName,
    required this.progress,
    this.avatarId,
    this.isReady = false,
    this.connectionState = ParticipantConnectionState.connected,
    this.finishedAt,
    this.latestEmoteId,
    this.latestEmoteAt,
  });

  final String uid;
  final String displayName;
  final String? avatarId;
  final bool isReady;
  final ParticipantConnectionState connectionState;
  final MatchProgress progress;
  final DateTime? finishedAt;

  /// Social-only expression. It never affects score, timing, ranking or rewards.
  final String? latestEmoteId;
  final DateTime? latestEmoteAt;

  bool get isFinished => finishedAt != null;

  bool emoteIsVisible(DateTime now) =>
      latestEmoteId != null &&
      latestEmoteAt != null &&
      now.difference(latestEmoteAt!).inSeconds.abs() <= 4;
}

class MultiplayerMatch {
  const MultiplayerMatch({
    required this.id,
    required this.mode,
    required this.hostUid,
    required this.maxPlayers,
    required this.seed,
    required this.registryVersion,
    required this.participants,
    this.roomCode,
    this.countdownStartedAt,
  });

  final String id;
  final MatchMode mode;
  final String hostUid;
  final int maxPlayers;
  final int seed;
  final int registryVersion;
  final List<MatchParticipant> participants;
  final String? roomCode;
  final DateTime? countdownStartedAt;

  bool get isFull => participants.length == maxPlayers;
  bool get everyoneReady =>
      participants.length == maxPlayers && participants.every((p) => p.isReady);
}

class MultiplayerMatchPolicy {
  const MultiplayerMatchPolicy._();

  static const Set<int> supportedPlayerCounts = <int>{2, 4, 6};

  static void validate(MultiplayerMatch match) {
    if (!supportedPlayerCounts.contains(match.maxPlayers)) {
      throw ArgumentError('Only 2, 4, or 6 player matches are supported.');
    }
    if (match.id.trim().isEmpty || match.hostUid.trim().isEmpty) {
      throw ArgumentError('Match identity is required.');
    }
    if (match.participants.isEmpty ||
        match.participants.length > match.maxPlayers) {
      throw StateError('Participant count is invalid.');
    }
    final ids = match.participants.map((p) => p.uid).toSet();
    if (ids.length != match.participants.length) {
      throw StateError('Duplicate participants are not allowed.');
    }
    if (!ids.contains(match.hostUid)) {
      throw StateError('Host must be a match participant.');
    }
    if (match.mode == MatchMode.ranked && match.maxPlayers != 2) {
      throw StateError('Ranked launch mode is strictly 1v1.');
    }
  }

  static bool awardsRankPoints(MatchMode mode) => mode == MatchMode.ranked;

  static bool usesReducedSocialRewards(MatchMode mode) =>
      mode == MatchMode.privateRoom || mode == MatchMode.party;
}
