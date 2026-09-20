import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/game_audio_controller.dart';
import '../data/match_backend.dart';
import 'match_play_screen.dart';

class AudioMatchPlayScreen extends StatefulWidget {
  const AudioMatchPlayScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final MatchBackend matchBackend;

  @override
  State<AudioMatchPlayScreen> createState() => _AudioMatchPlayScreenState();
}

class _AudioMatchPlayScreenState extends State<AudioMatchPlayScreen> {
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
    return MatchPlayScreen(
      matchId: widget.matchId,
      uid: widget.uid,
      matchBackend: widget.matchBackend,
    );
  }
}
