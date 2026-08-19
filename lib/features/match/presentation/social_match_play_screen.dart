import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/game_audio_controller.dart';
import '../data/social_match_backend.dart';
import 'social_match_play_core_screen.dart' as core;

/// Audio-owned entry point for all Private/Party social matches.
/// The gameplay implementation stays isolated in the core screen so audio
/// cannot change evidence, timing, settlement, scoring or emote behavior.
class SocialMatchPlayScreen extends StatefulWidget {
  const SocialMatchPlayScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final SocialMatchBackend matchBackend;

  @override
  State<SocialMatchPlayScreen> createState() => _SocialMatchPlayScreenState();
}

class _SocialMatchPlayScreenState extends State<SocialMatchPlayScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(GameAudioController.instance.playSfx(GameSfx.matchStart));
    unawaited(GameAudioController.instance.playMatchMusic());
  }

  @override
  void dispose() {
    unawaited(GameAudioController.instance.playMenuMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return core.SocialMatchPlayScreen(
      matchId: widget.matchId,
      uid: widget.uid,
      matchBackend: widget.matchBackend,
    );
  }
}
