class CosmeticLoadout {
  const CosmeticLoadout({
    this.avatarId,
    this.avatarFrameId,
    this.badgeId,
    this.profileBackgroundId,
    this.nameStyleId,
    this.matchIntroId,
    this.victoryEffectId,
    this.rankAuraId,
    this.emoteId,
    this.roomThemeId,
  });

  final String? avatarId;
  final String? avatarFrameId;
  final String? badgeId;
  final String? profileBackgroundId;
  final String? nameStyleId;
  final String? matchIntroId;
  final String? victoryEffectId;
  final String? rankAuraId;
  final String? emoteId;
  final String? roomThemeId;

  bool get isEmpty =>
      avatarId == null &&
      avatarFrameId == null &&
      badgeId == null &&
      profileBackgroundId == null &&
      nameStyleId == null &&
      matchIntroId == null &&
      victoryEffectId == null &&
      rankAuraId == null &&
      emoteId == null &&
      roomThemeId == null;

  static CosmeticLoadout fromMap(Map<String, dynamic>? data) {
    String? value(String key) {
      final raw = data?[key];
      return raw is String && raw.isNotEmpty ? raw : null;
    }

    return CosmeticLoadout(
      avatarId: value('equippedAvatarId'),
      avatarFrameId: value('equippedAvatarFrameId'),
      badgeId: value('equippedBadgeId'),
      profileBackgroundId: value('equippedProfileBackgroundId'),
      nameStyleId: value('equippedNameStyleId'),
      matchIntroId: value('equippedMatchIntroId'),
      victoryEffectId: value('equippedVictoryEffectId'),
      rankAuraId: value('equippedRankAuraId'),
      emoteId: value('equippedEmoteId'),
      roomThemeId: value('equippedRoomThemeId'),
    );
  }
}
