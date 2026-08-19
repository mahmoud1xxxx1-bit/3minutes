import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AvatarArtwork extends StatelessWidget {
  const AvatarArtwork({
    super.key,
    required this.avatarId,
    this.size = 72,
    this.borderRadius = 22,
  });

  final String avatarId;
  final double size;
  final double borderRadius;

  static const _atlasPaths = <String>[
    'assets/avatars/free_atlas.webp.b64',
    'assets/avatars/coins_atlas.webp.b64',
    'assets/avatars/premium_atlas.webp.b64',
    'assets/avatars/stars_atlas.webp.b64',
    'assets/avatars/exclusive_atlas.webp.b64',
  ];

  static final Map<String, Uint8List> _resolvedBytes = <String, Uint8List>{};
  static final Map<String, Future<Uint8List>> _pendingLoads = <String, Future<Uint8List>>{};

  static bool supports(String id) => _specFor(id) != null;

  /// Warms all approved avatar atlases before the player enters the main shell.
  /// This removes repeated base64 decode spinners while browsing Shop/Profile.
  static Future<void> preloadAll() async {
    await Future.wait(_atlasPaths.map(_load));
  }

  static Future<Uint8List> _load(String assetPath) {
    final ready = _resolvedBytes[assetPath];
    if (ready != null) return Future<Uint8List>.value(ready);
    return _pendingLoads.putIfAbsent(assetPath, () async {
      final encoded = (await rootBundle.loadString(assetPath)).trim();
      final bytes = base64Decode(encoded);
      _resolvedBytes[assetPath] = bytes;
      _pendingLoads.remove(assetPath);
      return bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(avatarId);
    if (spec == null) {
      return SizedBox.square(
        dimension: size,
        child: const Icon(Icons.person_rounded),
      );
    }

    final ready = _resolvedBytes[spec.assetPath];
    if (ready != null) return _render(spec, ready);

    return FutureBuilder<Uint8List>(
      future: _load(spec.assetPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.square(
            dimension: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF11182D),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Color(0x668CD9FF)),
              ),
            ),
          );
        }
        return _render(spec, snapshot.data!);
      },
    );
  }

  Widget _render(_AvatarAtlasSpec spec, Uint8List bytes) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -spec.column * size,
                top: -spec.row * size,
                width: spec.columns * size,
                height: spec.rows * size,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _AvatarAtlasSpec? _specFor(String id) {
    if (id.startsWith('avatar_free_')) {
      const ids = [
        'avatar_free_vanguard',
        'avatar_free_arena',
        'avatar_free_hacker',
        'avatar_free_phantom',
        'avatar_free_warden',
      ];
      final index = ids.indexOf(id);
      if (index >= 0) {
        return _AvatarAtlasSpec(
          assetPath: 'assets/avatars/free_atlas.webp.b64',
          index: index,
          rows: 1,
        );
      }
    }

    final coin = _numberedIndex(id, 'avatar_coin_', 20);
    if (coin != null) {
      return _AvatarAtlasSpec(
        assetPath: 'assets/avatars/coins_atlas.webp.b64',
        index: coin,
        rows: 4,
      );
    }
    final premium = _numberedIndex(id, 'avatar_premium_', 10);
    if (premium != null) {
      return _AvatarAtlasSpec(
        assetPath: 'assets/avatars/premium_atlas.webp.b64',
        index: premium,
        rows: 2,
      );
    }
    final stars = _numberedIndex(id, 'avatar_star_', 5);
    if (stars != null) {
      return _AvatarAtlasSpec(
        assetPath: 'assets/avatars/stars_atlas.webp.b64',
        index: stars,
        rows: 1,
      );
    }
    final exclusive = _numberedIndex(id, 'avatar_exclusive_', 5);
    if (exclusive != null) {
      return _AvatarAtlasSpec(
        assetPath: 'assets/avatars/exclusive_atlas.webp.b64',
        index: exclusive,
        rows: 1,
      );
    }
    return null;
  }

  static int? _numberedIndex(String id, String prefix, int count) {
    if (!id.startsWith(prefix)) return null;
    final value = int.tryParse(id.substring(prefix.length));
    if (value == null || value < 1 || value > count) return null;
    return value - 1;
  }
}

class _AvatarAtlasSpec {
  const _AvatarAtlasSpec({
    required this.assetPath,
    required this.index,
    required this.rows,
  });

  final String assetPath;
  final int index;
  final int rows;
  int get columns => 5;
  int get column => index % columns;
  int get row => index ~/ columns;
}
