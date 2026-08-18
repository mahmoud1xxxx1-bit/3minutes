import '../../competition/domain/mini_game_evidence.dart';
import '../domain/match_progress.dart';
import '../domain/multiplayer_match.dart';

abstract class SocialMatchBackend {
  Stream<MultiplayerMatch?> watchMatch(String matchId);

  Future<MultiplayerMatch> createMatch({
    required String roomId,
    required String roomCode,
    required String hostUid,
    required int maxPlayers,
    required List<MatchParticipant> participants,
  });

  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required MiniGameEvidence evidence,
  });

  Future<void> setConnectionState({
    required String matchId,
    required String uid,
    required ParticipantConnectionState state,
  });

  Future<void> settleMatch(String matchId);
}
