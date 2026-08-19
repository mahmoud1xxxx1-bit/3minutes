import 'dart:async';

import 'package:flutter/material.dart';

import 'game_audio_controller.dart';

/// Owns the experiential audio scene for a live gameplay route.
///
/// Entering the scope switches to the focused match loop and plays the
/// match-start cue once. Leaving restores the menu ambience. Audio failures
/// remain fail-soft inside [GameAudioController] and never affect gameplay.
class MatchAudioScope extends StatefulWidget {
  const MatchAudioScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MatchAudioScope> createState() => _MatchAudioScopeState();
}

class _MatchAudioScopeState extends State<MatchAudioScope> {
  @override
  void initState() {
    super.initState();
    unawaited(_enter());
  }

  Future<void> _enter() async {
    await GameAudioController.instance.playMatchMusic();
    await GameAudioController.instance.playSfx(GameSfx.matchStart);
  }

  @override
  void dispose() {
    unawaited(GameAudioController.instance.playMenuMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
