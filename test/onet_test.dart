// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/presentation/onet_connect/onet_connect_game.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';

void main() {
  testWidgets('OnetConnectGame test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR: ' + details.exceptionAsString());
    };
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnetConnectGame(
          config: const MiniGameConfig(seed: 1234, difficulty: 1),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  });
}

