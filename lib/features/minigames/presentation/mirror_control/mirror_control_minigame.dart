import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'game_engine.dart';
import '../mini_game_copy.dart';
import 'painter_a1_forest.dart';
import 'painter_a2_ocean.dart';
import 'painter_a3_heist.dart';
import 'painter_a4_biology.dart';
import 'painter_a5_wildwest.dart';
import 'painter_a6_frozen.dart';
import 'painter_a7_graveyard.dart';
import 'painter_a8_neon.dart';
import 'painter_a9_volcano.dart';
import 'painter_a10_candyland.dart';
import 'painter_a11_ninja.dart';
import 'painter_a12_space.dart';
import 'painter_a13_retro.dart';
import 'painter_a14_dino.dart';
import 'painter_a15_steampunk.dart';
import 'painter_a16_pirate.dart';
import 'painter_a17_egypt.dart';
import 'painter_a18_toy.dart';
import 'painter_a19_zen.dart';
import 'painter_a20_alien.dart';
import 'painter_a21_castle.dart';
import 'painter_a22_factory.dart';
import 'painter_a23_sky.dart';
import 'painter_a24_music.dart';
import 'painter_a25_chip.dart';
import 'painter_a26_desert.dart';
import 'painter_a27_library.dart';
import 'painter_a28_casino.dart';
import 'painter_a29_bee.dart';
import 'painter_a30_void.dart';
import 'painter_a31.dart';
import 'painter_a32.dart';
import 'painter_a33.dart';
import 'painter_a34.dart';
import 'painter_a35.dart';
import 'painter_a36.dart';
import 'painter_a37.dart';
import 'painter_a38.dart';
import 'painter_a39.dart';
import 'painter_a40.dart';
import 'painter_a41.dart';
import 'painter_a42.dart';
import 'painter_a43.dart';
import 'painter_a44.dart';
import 'painter_a45.dart';
import 'painter_a46.dart';
import 'painter_a47.dart';
import 'painter_a48.dart';
import 'painter_a49.dart';
import 'painter_a50.dart';
import 'painter_a51.dart';
import 'painter_a52.dart';
import 'painter_a53.dart';
import 'painter_a54.dart';
import 'painter_a55.dart';
import 'painter_a56.dart';
import 'painter_a57.dart';
import 'painter_a58.dart';
import 'painter_a59.dart';
import 'painter_a60.dart';
import 'painter_a61.dart';
import 'painter_a62.dart';
import 'painter_a63.dart';
import 'painter_a64.dart';
import 'painter_a65.dart';
import 'painter_a66.dart';
import 'painter_a67.dart';
import 'painter_a68.dart';
import 'painter_a69.dart';
import 'painter_a70.dart';
import 'painter_a71.dart';
import 'painter_a72.dart';
import 'painter_a73.dart';
import 'painter_a74.dart';
import 'painter_a75.dart';
import 'painter_a76.dart';
import 'painter_a77.dart';
import 'painter_a78.dart';
import 'painter_a79.dart';
import 'painter_a80.dart';
import 'painter_a81.dart';
import 'painter_a82.dart';
import 'painter_a83.dart';
import 'painter_a84.dart';
import 'painter_a85.dart';
import 'painter_a86.dart';
import 'painter_a87.dart';
import 'painter_a88.dart';
import 'painter_a89.dart';
import 'painter_a90.dart';
import 'painter_a91.dart';
import 'painter_a92.dart';
import 'painter_a93.dart';
import 'painter_a94.dart';
import 'painter_a95.dart';
import 'painter_a96.dart';
import 'painter_a97.dart';
import 'painter_a98.dart';
import 'painter_a99.dart';
import 'painter_a100.dart';
import 'painter_a101.dart';
import 'painter_a102.dart';
import 'painter_a103.dart';
import 'painter_a104.dart';
import 'painter_a105.dart';


import '../../domain/mini_game_contract.dart';
import '../shared/minigame_environment.dart';





class MirrorControlMiniGame extends StatefulWidget {
  const MirrorControlMiniGame({
    Key? key,
    required this.config,
    required this.onComplete,
  }) : super(key: key);

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<MirrorControlMiniGame> createState() => _MirrorControlMiniGameState();
}

class _MirrorControlMiniGameState extends State<MirrorControlMiniGame> with SingleTickerProviderStateMixin {
  late GameEngine engine;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  Offset _dragVector = Offset.zero;
  bool _assetsLoaded = false;
  final Map<String, ui.Image> _images = {};
  
  bool _hasCompleted = false;
  late int stageIndex;
  late String themeId;

  @override
  void initState() {
    super.initState();
    // Deterministic Stage Selection
    stageIndex = (widget.config.seed % 105) + 1;
    themeId = 'a$stageIndex';
    
    // Deterministic Engine Initialization
    engine = GameEngine(seed: widget.config.seed);
    _loadAssets();

    _ticker = createTicker((elapsed) {
      if (!_assetsLoaded || _hasCompleted) return;
      
      if (_lastTime == Duration.zero) {
        _lastTime = elapsed;
        return;
      }
      final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
      _lastTime = elapsed;
      Offset inputVector = _dragVector;
      if (inputVector.distance > 0.1) inputVector = inputVector / inputVector.distance;
      
      int oldTargets = engine.currentTargetIndex;
      int oldMistakes = engine.mistakes;

      engine.update(dt, inputVector);

      if (mounted) {
        if (engine.currentTargetIndex > oldTargets) {
          MinigameEnvironment.of(context).updateScore(engine.currentTargetIndex * 100);
          MinigameEnvironment.of(context).playSuccess(Offset.zero);
        }
        if (engine.mistakes > oldMistakes) {
          MinigameEnvironment.of(context).playError(Offset.zero);
        }
        // Mirror Control usually has a 30s par time for visual
        MinigameEnvironment.of(context).updateTimeProgress((engine.time / 30.0).clamp(0.0, 1.0));
      }
      
      if (engine.isCompleted && !_hasCompleted) {
        _hasCompleted = true;
        _hasCompleted = true;
        
        // Calculate Contract Result
        int mistakes = engine.mistakes;
        int durationMs = engine.time.toInt() * 1000;
        
        int score = math.max(0, 100 - (mistakes * 5) - ((durationMs ~/ 1000) ~/ 2));
        double accuracy = math.max(0.0, 1.0 - (mistakes / 10.0));
        
        widget.onComplete(MiniGameResult(
          completed: true,
          score: score,
          accuracy: accuracy,
          mistakes: mistakes,
          duration: Duration(milliseconds: durationMs),
        ));
      }
      setState(() {});
    });
    _ticker.start();
  }

  Future<void> _loadAssets() async {
    _images['player'] = await _loadImage('assets/mirror_control/player.png');
    _images['enemy'] = await _loadImage('assets/mirror_control/enemy.png');
    _images['target'] = await _loadImage('assets/mirror_control/target.png');
    if (mounted) setState(() { _assetsLoaded = true; });
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  CustomPainter getPainter() {
    return _getPainterForTheme(themeId);
  }
  
    CustomPainter _getPainterForTheme(String theme) {
    if (theme == 'a1') return GamePainterA1Forest(engine: engine, images: _images);
    if (theme == 'a2') return GamePainterA2Ocean(engine: engine, images: _images);
    if (theme == 'a3') return GamePainterA3Heist(engine: engine, images: _images);
    if (theme == 'a4') return GamePainterA4Biology(engine: engine, images: _images);
    if (theme == 'a5') return GamePainterA5WildWest(engine: engine, images: _images);
    if (theme == 'a6') return GamePainterA6Frozen(engine: engine, images: _images);
    if (theme == 'a7') return GamePainterA7Graveyard(engine: engine, images: _images);
    if (theme == 'a8') return GamePainterA8Neon(engine: engine, images: _images);
    if (theme == 'a9') return GamePainterA9Volcano(engine: engine, images: _images);
    if (theme == 'a10') return GamePainterA10Candyland(engine: engine, images: _images);
    if (theme == 'a11') return GamePainterA11Ninja(engine: engine, images: _images);
    if (theme == 'a12') return GamePainterA12Space(engine: engine, images: _images);
    if (theme == 'a13') return GamePainterA13Retro(engine: engine, images: _images);
    if (theme == 'a14') return GamePainterA14Dino(engine: engine, images: _images);
    if (theme == 'a15') return GamePainterA15Steampunk(engine: engine, images: _images);
    if (theme == 'a16') return GamePainterA16Pirate(engine: engine, images: _images);
    if (theme == 'a17') return GamePainterA17Egypt(engine: engine, images: _images);
    if (theme == 'a18') return GamePainterA18Toy(engine: engine, images: _images);
    if (theme == 'a19') return GamePainterA19Zen(engine: engine, images: _images);
    if (theme == 'a20') return GamePainterA20Alien(engine: engine, images: _images);
    if (theme == 'a21') return GamePainterA21Castle(engine: engine, images: _images);
    if (theme == 'a22') return GamePainterA22Factory(engine: engine, images: _images);
    if (theme == 'a23') return GamePainterA23Sky(engine: engine, images: _images);
    if (theme == 'a24') return GamePainterA24Music(engine: engine, images: _images);
    if (theme == 'a25') return GamePainterA25Chip(engine: engine, images: _images);
    if (theme == 'a26') return GamePainterA26Desert(engine: engine, images: _images);
    if (theme == 'a27') return GamePainterA27Library(engine: engine, images: _images);
    if (theme == 'a28') return GamePainterA28Casino(engine: engine, images: _images);
    if (theme == 'a29') return GamePainterA29Bee(engine: engine, images: _images);
    if (theme == 'a30') return GamePainterA30Void(engine: engine, images: _images);
    if (theme == 'a31') return GamePainterA31(engine: engine, images: _images);
    if (theme == 'a32') return GamePainterA32(engine: engine, images: _images);
    if (theme == 'a33') return GamePainterA33(engine: engine, images: _images);
    if (theme == 'a34') return GamePainterA34(engine: engine, images: _images);
    if (theme == 'a35') return GamePainterA35(engine: engine, images: _images);
    if (theme == 'a36') return GamePainterA36(engine: engine, images: _images);
    if (theme == 'a37') return GamePainterA37(engine: engine, images: _images);
    if (theme == 'a38') return GamePainterA38(engine: engine, images: _images);
    if (theme == 'a39') return GamePainterA39(engine: engine, images: _images);
    if (theme == 'a40') return GamePainterA40(engine: engine, images: _images);
    if (theme == 'a41') return GamePainterA41(engine: engine, images: _images);
    if (theme == 'a42') return GamePainterA42(engine: engine, images: _images);
    if (theme == 'a43') return GamePainterA43(engine: engine, images: _images);
    if (theme == 'a44') return GamePainterA44(engine: engine, images: _images);
    if (theme == 'a45') return GamePainterA45(engine: engine, images: _images);
    if (theme == 'a46') return GamePainterA46(engine: engine, images: _images);
    if (theme == 'a47') return GamePainterA47(engine: engine, images: _images);
    if (theme == 'a48') return GamePainterA48(engine: engine, images: _images);
    if (theme == 'a49') return GamePainterA49(engine: engine, images: _images);
    if (theme == 'a50') return GamePainterA50(engine: engine, images: _images);
    if (theme == 'a51') return GamePainterA51(engine: engine, images: _images);
    if (theme == 'a52') return GamePainterA52(engine: engine, images: _images);
    if (theme == 'a53') return GamePainterA53(engine: engine, images: _images);
    if (theme == 'a54') return GamePainterA54(engine: engine, images: _images);
    if (theme == 'a55') return GamePainterA55(engine: engine, images: _images);
    if (theme == 'a56') return GamePainterA56(engine: engine, images: _images);
    if (theme == 'a57') return GamePainterA57(engine: engine, images: _images);
    if (theme == 'a58') return GamePainterA58(engine: engine, images: _images);
    if (theme == 'a59') return GamePainterA59(engine: engine, images: _images);
    if (theme == 'a60') return GamePainterA60(engine: engine, images: _images);
    if (theme == 'a61') return GamePainterA61(engine: engine, images: _images);
    if (theme == 'a62') return GamePainterA62(engine: engine, images: _images);
    if (theme == 'a63') return GamePainterA63(engine: engine, images: _images);
    if (theme == 'a64') return GamePainterA64(engine: engine, images: _images);
    if (theme == 'a65') return GamePainterA65(engine: engine, images: _images);
    if (theme == 'a66') return GamePainterA66(engine: engine, images: _images);
    if (theme == 'a67') return GamePainterA67(engine: engine, images: _images);
    if (theme == 'a68') return GamePainterA68(engine: engine, images: _images);
    if (theme == 'a69') return GamePainterA69(engine: engine, images: _images);
    if (theme == 'a70') return GamePainterA70(engine: engine, images: _images);
    if (theme == 'a71') return GamePainterA71(engine: engine, images: _images);
    if (theme == 'a72') return GamePainterA72(engine: engine, images: _images);
    if (theme == 'a73') return GamePainterA73(engine: engine, images: _images);
    if (theme == 'a74') return GamePainterA74(engine: engine, images: _images);
    if (theme == 'a75') return GamePainterA75(engine: engine, images: _images);
    if (theme == 'a76') return GamePainterA76(engine: engine, images: _images);
    if (theme == 'a77') return GamePainterA77(engine: engine, images: _images);
    if (theme == 'a78') return GamePainterA78(engine: engine, images: _images);
    if (theme == 'a79') return GamePainterA79(engine: engine, images: _images);
    if (theme == 'a80') return GamePainterA80(engine: engine, images: _images);
    if (theme == 'a81') return GamePainterA81(engine: engine, images: _images);
    if (theme == 'a82') return GamePainterA82(engine: engine, images: _images);
    if (theme == 'a83') return GamePainterA83(engine: engine, images: _images);
    if (theme == 'a84') return GamePainterA84(engine: engine, images: _images);
    if (theme == 'a85') return GamePainterA85(engine: engine, images: _images);
    if (theme == 'a86') return GamePainterA86(engine: engine, images: _images);
    if (theme == 'a87') return GamePainterA87(engine: engine, images: _images);
    if (theme == 'a88') return GamePainterA88(engine: engine, images: _images);
    if (theme == 'a89') return GamePainterA89(engine: engine, images: _images);
    if (theme == 'a90') return GamePainterA90(engine: engine, images: _images);
    if (theme == 'a91') return GamePainterA91(engine: engine, images: _images);
    if (theme == 'a92') return GamePainterA92(engine: engine, images: _images);
    if (theme == 'a93') return GamePainterA93(engine: engine, images: _images);
    if (theme == 'a94') return GamePainterA94(engine: engine, images: _images);
    if (theme == 'a95') return GamePainterA95(engine: engine, images: _images);
    if (theme == 'a96') return GamePainterA96(engine: engine, images: _images);
    if (theme == 'a97') return GamePainterA97(engine: engine, images: _images);
    if (theme == 'a98') return GamePainterA98(engine: engine, images: _images);
    if (theme == 'a99') return GamePainterA99(engine: engine, images: _images);
    if (theme == 'a100') return GamePainterA100(engine: engine, images: _images);
    if (theme == 'a101') return GamePainterA101(engine: engine, images: _images);
    if (theme == 'a102') return GamePainterA102(engine: engine, images: _images);
    if (theme == 'a103') return GamePainterA103(engine: engine, images: _images);
    if (theme == 'a104') return GamePainterA104(engine: engine, images: _images);
    if (theme == 'a105') return GamePainterA105(engine: engine, images: _images);
    return GamePainterA1Forest(engine: engine, images: _images);
  }

  @override
  Widget build(BuildContext context) {
    if (!_assetsLoaded) return const Center(child: CircularProgressIndicator());
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onPanStart: (d) => _dragVector = Offset.zero,
        onPanUpdate: (d) {
          final scaleX = context.size!.width / GameEngine.fieldSize;
          final scaleY = context.size!.height / GameEngine.fieldSize;
          final scale = math.min(scaleX, scaleY);
          _dragVector += Offset(-d.delta.dx, -d.delta.dy) / scale;
        },
        onPanEnd: (d) => _dragVector = Offset.zero,
        child: CustomPaint(painter: getPainter(), size: Size.infinite),
      ),
    );
  }
}


