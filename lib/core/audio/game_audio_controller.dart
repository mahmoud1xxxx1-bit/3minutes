import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../settings/game_settings_controller.dart';

enum GameAudioScene { silent, menu, match }

enum GameSfx { tap, reward, matchStart }

class GameAudioController {
  GameAudioController._();

  static final GameAudioController instance = GameAudioController._();

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: '3minutes_music');
  final AudioPlayer _sfxPlayer = AudioPlayer(playerId: '3minutes_sfx');
  final GameSettingsController _settings = GameSettingsController.instance;

  GameAudioScene _scene = GameAudioScene.silent;
  bool _initialized = false;

  GameAudioScene get scene => _scene;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _settings.addListener(_applyVolumes);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _applyVolumes();
  }

  Future<void> dispose() async {
    _settings.removeListener(_applyVolumes);
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }

  Future<void> _applyVolumes() async {
    if (!_initialized) return;
    try {
      await _musicPlayer.setVolume(_settings.effectiveMusicVolume);
      await _sfxPlayer.setVolume(_settings.effectiveSfxVolume);
    } catch (_) {
      // Audio is experiential only. Never let an audio-device failure block gameplay.
    }
  }

  Future<void> playMenuMusic() => _switchScene(
        GameAudioScene.menu,
        const AssetSource('audio/menu_ambient.ogg'),
      );

  Future<void> playMatchMusic() => _switchScene(
        GameAudioScene.match,
        const AssetSource('audio/match_focus.ogg'),
      );

  Future<void> stopMusic() async {
    _scene = GameAudioScene.silent;
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> _switchScene(GameAudioScene scene, AssetSource source) async {
    if (!_initialized) await initialize();
    if (_scene == scene && _musicPlayer.state == PlayerState.playing) {
      await _applyVolumes();
      return;
    }
    _scene = scene;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_settings.effectiveMusicVolume);
      await _musicPlayer.play(source);
    } catch (_) {
      // Fail soft: a device audio problem must never interrupt a match.
    }
  }

  Future<void> playSfx(GameSfx effect) async {
    if (!_initialized) await initialize();
    if (_settings.effectiveSfxVolume <= 0) return;
    final source = switch (effect) {
      GameSfx.tap => const AssetSource('audio/ui_tap.ogg'),
      GameSfx.reward => const AssetSource('audio/reward.ogg'),
      GameSfx.matchStart => const AssetSource('audio/match_start.ogg'),
    };
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_settings.effectiveSfxVolume);
      await _sfxPlayer.play(source);
    } catch (_) {}
  }
}
