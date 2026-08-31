import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/domain/player_profile.dart';
import '../data/firestore_party_backend.dart';
import '../data/room_backend.dart';
import '../data/social_backend.dart';
import '../domain/private_room.dart';
import 'party_screen.dart';
import 'private_room_screen.dart';
import 'social_copy.dart';

class RoomHubScreen extends StatefulWidget {
  const RoomHubScreen({
    super.key,
    required this.profile,
    required this.roomBackend,
    required this.socialBackend,
    required this.socialMatchBackend,
    this.initialRoomCode,
  });

  final PlayerProfile profile;
  final RoomBackend roomBackend;
  final SocialBackend socialBackend;
  final SocialMatchBackend socialMatchBackend;
  final String? initialRoomCode;

  @override
  State<RoomHubScreen> createState() => _RoomHubScreenState();
}

class _RoomHubScreenState extends State<RoomHubScreen> {
  final _roomCodeController = TextEditingController();
  bool _busy = false;
  String? _error;
  int _selectedPlayers = 4;

  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  void initState() {
    super.initState();
    final code = widget.initialRoomCode?.trim().toUpperCase();
    if (code != null && PrivateRoomPolicy.validCode(code)) {
      _roomCodeController.text = code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _join();
      });
    }
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  String _newCode() {
    final random = Random.secure();
    return List.generate(
      5,
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
  }

  Future<void> _create(int maxPlayers) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      PrivateRoom? room;
      for (var attempt = 0; attempt < 5 && room == null; attempt++) {
        try {
          room = await widget.roomBackend.createRoom(
            hostUid: widget.profile.uid,
            maxPlayers: maxPlayers,
            roomCode: _newCode(),
          );
        } catch (_) {
          if (attempt == 4) rethrow;
        }
      }
      if (!mounted || room == null) return;
      await _openRoom(room);
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    if (_busy) return;
    final copy = SocialCopy.of(context);
    final code = _roomCodeController.text.trim().toUpperCase();
    if (!PrivateRoomPolicy.validCode(code)) {
      setState(() => _error = copy.invalidRoomCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final room = await widget.roomBackend.findRoomByCode(code);
      if (room == null) {
        if (mounted) setState(() => _error = copy.roomNotFound);
        return;
      }
      await widget.roomBackend.joinRoom(
        roomId: room.id,
        uid: widget.profile.uid,
      );
      if (!mounted) return;
      await _openRoom(room);
    } catch (_) {
      if (mounted) setState(() => _error = copy.socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openRoom(PrivateRoom room) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivateRoomScreen(
          initialRoom: room,
          profile: widget.profile,
          roomBackend: widget.roomBackend,
          socialBackend: widget.socialBackend,
          socialMatchBackend: widget.socialMatchBackend,
        ),
      ),
    );
  }

  void _openParty() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PartyScreen(
          profile: widget.profile,
          partyBackend: FirestorePartyBackend(),
          roomBackend: widget.roomBackend,
          socialBackend: widget.socialBackend,
          socialMatchBackend: widget.socialMatchBackend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.squad,
              size: 25,
              color: GameColors.violet,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(copy.playWithFriends),
          ],
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              GameSpacing.sm,
              GameSpacing.md,
              GameSpacing.xl,
            ),
            children: [
              _RoomHero(copy: copy, ar: ar),
              const SizedBox(height: GameSpacing.md),
              ArenaCard(
                accent: GameColors.violet,
                glow: true,
                onTap: _openParty,
                child: Row(
                  children: [
                    const _GlyphPlate(
                      glyph: GameGlyphType.squad,
                      color: GameColors.violet,
                    ),
                    const SizedBox(width: GameSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.party,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            copy.partySubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '›',
                      style: TextStyle(color: GameColors.violet, fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaSectionTitle(
                title: copy.createRoom,
                subtitle: ar
                    ? 'اختر حجم الغرفة ثم أنشئ كود تحدٍ خاص.'
                    : 'Choose room size and generate a private challenge code.',
                trailing: const GameGlyph(
                  type: GameGlyphType.battle,
                  size: 24,
                  color: GameColors.accentBright,
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              ArenaCard(
                accent: GameColors.accentBright,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _PlayerCountChoice(
                          count: 2,
                          label: copy.players2,
                          selected: _selectedPlayers == 2,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 2),
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        _PlayerCountChoice(
                          count: 4,
                          label: copy.players4,
                          selected: _selectedPlayers == 4,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 4),
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        _PlayerCountChoice(
                          count: 6,
                          label: copy.players6,
                          selected: _selectedPlayers == 6,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 6),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
                    ArenaPlayButton(
                      title: copy.createRoom,
                      subtitle: ar
                          ? 'كود خاص • إعداد فوري • دعوة أصدقاء'
                          : 'Private code • instant setup • invite friends',
                      icon: Icons.add_rounded,
                      onPressed: _busy ? null : () => _create(_selectedPlayers),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaSectionTitle(
                title: copy.joinRoom,
                subtitle: ar
                    ? 'أدخل رمز الغرفة المكوّن من 5 خانات.'
                    : 'Enter the 5-character room code.',
                trailing: const GameGlyph(
                  type: GameGlyphType.identity,
                  size: 24,
                  color: GameColors.rewardGold,
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              ArenaCard(
                accent: GameColors.rewardGold,
                child: Column(
                  children: [
                    TextField(
                      controller: _roomCodeController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ABCDE',
                        counterText: '',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: GameGlyph(
                            type: GameGlyphType.identity,
                            size: 22,
                            color: GameColors.rewardGold,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _join(),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    ArenaPlayButton(
                      title: _busy ? copy.joiningRoom : copy.joinRoom,
                      subtitle: ar
                          ? 'اتصل بالغرفة وادخل لوبي التحدي'
                          : 'Connect and enter the challenge lobby',
                      icon: Icons.login_rounded,
                      primary: false,
                      onPressed: _busy ? null : _join,
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: GameSpacing.md),
                ArenaCard(
                  accent: GameColors.danger,
                  child: Row(
                    children: [
                      const GameGlyph(
                        type: GameGlyphType.shield,
                        size: 25,
                        color: GameColors.danger,
                      ),
                      const SizedBox(width: GameSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: GameColors.danger, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomHero extends StatelessWidget {
  const _RoomHero({required this.copy, required this.ar});
  final SocialCopy copy;
  final bool ar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17334F), Color(0xFF2A214F), Color(0xFF09152C)],
        ),
        border: Border.all(color: GameColors.violet.withValues(alpha: .30)),
        boxShadow: const [BoxShadow(color: Color(0x302B72FF), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Row(
        children: [
          const _GlyphPlate(
            glyph: GameGlyphType.battle,
            color: GameColors.accentBright,
            large: true,
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.privateRoom,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  copy.roomRule,
                  style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.45),
                ),
                const SizedBox(height: 9),
                ArenaPill(
                  label: copy.roomNoRankedRp,
                  color: GameColors.rewardGold,
                  solid: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlyphPlate extends StatelessWidget {
  const _GlyphPlate({required this.glyph, required this.color, this.large = false});
  final GameGlyphType glyph;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final side = large ? 68.0 : 54.0;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(large ? 22 : 18),
        border: Border.all(color: color.withValues(alpha: .26)),
      ),
      alignment: Alignment.center,
      child: GameGlyph(
        type: glyph,
        size: large ? 36 : 29,
        color: color,
        active: true,
      ),
    );
  }
}

class _PlayerCountChoice extends StatelessWidget {
  const _PlayerCountChoice({
    required this.count,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GameColors.accentBright : GameColors.textSoft;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: GameDurations.normal,
          padding: const EdgeInsets.symmetric(vertical: GameSpacing.md),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [Color(0x3320E4EA), Color(0x227957F5)])
                : null,
            color: selected ? null : GameColors.surfaceRaised,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? GameColors.accentBright.withValues(alpha: .52) : GameColors.surfaceStrong,
              width: selected ? 1.3 : .8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameGlyph(
                type: GameGlyphType.squad,
                size: 24,
                color: color,
                active: selected,
              ),
              const SizedBox(height: GameSpacing.xs),
              Text(
                '$count',
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700, fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
