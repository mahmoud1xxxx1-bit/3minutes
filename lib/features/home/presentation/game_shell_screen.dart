import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/audio/game_audio_controller.dart';
import '../../../core/platform/room_invite_service.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/game_dock.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_service.dart';
import '../../competition/data/competition_backend.dart';
import '../../competition/presentation/season_hub_screen.dart';
import '../../economy/data/economy_backend.dart';
import '../../economy/presentation/shop_screen.dart';
import '../../match/data/match_backend.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/arena_profile_hub.dart';
import '../../profile/presentation/profile_showcase_screen.dart';
import '../../progression/data/progression_backend.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../../social/presentation/arena_friends_hub.dart';
import '../../social/presentation/friends_screen.dart';
import '../../social/presentation/room_hub_screen.dart';
import '../../social/presentation/social_copy.dart';
import 'arena_home_screen.dart';

class GameShellScreen extends StatefulWidget {
  const GameShellScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.quickMatchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.progressionBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final MatchBackend quickMatchBackend;
  final SocialMatchBackend socialMatchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final ProgressionBackend progressionBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  @override
  State<GameShellScreen> createState() => _GameShellScreenState();
}

class _GameShellScreenState extends State<GameShellScreen> {
  int _index = 0;
  StreamSubscription<String>? _inviteSubscription;
  String? _pendingInviteCode;
  String? _openingInviteCode;

  @override
  void initState() {
    super.initState();
    unawaited(GameAudioController.instance.playMenuMusic());
    _inviteSubscription = RoomInviteService.roomCodes.listen(_queueInvite);
    unawaited(
      RoomInviteService.takeInitialRoomCode().then((code) {
        if (code != null) _queueInvite(code);
      }),
    );
  }

  @override
  void dispose() {
    unawaited(_inviteSubscription?.cancel());
    unawaited(GameAudioController.instance.stopMusic());
    super.dispose();
  }

  void _queueInvite(String code) {
    if (!mounted || code == _openingInviteCode) return;
    setState(() => _pendingInviteCode = code);
  }

  void _openPendingInvite(PlayerProfile profile) {
    final code = _pendingInviteCode;
    if (code == null || code == _openingInviteCode) return;
    _openingInviteCode = code;
    _pendingInviteCode = null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RoomHubScreen(
            profile: profile,
            roomBackend: widget.roomBackend,
            socialBackend: widget.socialBackend,
            socialMatchBackend: widget.socialMatchBackend,
            initialRoomCode: code,
          ),
        ),
      );
      if (mounted) _openingInviteCode = null;
    });
  }

  void _openProfileShowcase(PlayerProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileShowcaseScreen(
          profile: profile,
          profileRepository: widget.profileRepository,
          economyBackend: widget.economyBackend,
        ),
      ),
    );
  }

  void _openFriends(PlayerProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FriendsScreen(
          profile: profile,
          socialBackend: widget.socialBackend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final social = SocialCopy.of(context);

    return StreamBuilder<PlayerProfile?>(
      stream: widget.profileRepository.watchProfile(widget.user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return const Scaffold(
            body: CosmicBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (_pendingInviteCode != null && _openingInviteCode == null) {
          _openPendingInvite(profile);
        }

        final pages = <Widget>[
          ArenaHomeScreen(
            user: widget.user,
            authService: widget.authService,
            profileRepository: widget.profileRepository,
            matchBackend: widget.matchBackend,
            quickMatchBackend: widget.quickMatchBackend,
            socialMatchBackend: widget.socialMatchBackend,
            competitionBackend: widget.competitionBackend,
            economyBackend: widget.economyBackend,
            progressionBackend: widget.progressionBackend,
            socialBackend: widget.socialBackend,
            roomBackend: widget.roomBackend,
          ),
          SeasonHubScreen(
            uid: profile.uid,
            competitionBackend: widget.competitionBackend,
            progressionBackend: widget.progressionBackend,
          ),
          ArenaFriendsHub(
            profile: profile,
            socialBackend: widget.socialBackend,
            onOpenFriends: () => _openFriends(profile),
          ),
          ShopScreen(uid: profile.uid, economyBackend: widget.economyBackend),
          ArenaProfileHub(
            profile: profile,
            onOpenShowcase: () => _openProfileShowcase(profile),
          ),
        ];

        return Scaffold(
          extendBody: true,
          body: CosmicBackground(
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: GameDock(
            selectedIndex: _index,
            onSelected: (value) {
              unawaited(GameAudioController.instance.playSfx(GameSfx.tap));
              setState(() => _index = value);
            },
            labels: [
              l10n.home,
              l10n.season,
              social.friends,
              l10n.shop,
              l10n.profile,
            ],
          ),
        );
      },
    );
  }
}
