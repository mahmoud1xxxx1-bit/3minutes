import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'dart:io';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_01.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_02.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_03.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_04.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_05.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_06.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_07.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_08.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_09.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_10.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_11.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_12.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_13.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_14.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_15.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_16.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_17.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_18.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_19.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_20.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_21.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_22.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_23.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_24.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_25.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_26.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_27.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_28.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_29.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_30.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_31.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_32.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_33.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_34.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_35.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_36.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_37.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_38.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_39.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_40.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_41.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_42.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_43.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_44.dart';
import 'package:game/features/minigames/presentation/find_differences/puzzles/puzzle_45.dart';
void main() {
  group('Find Differences Integration & Constraints', () {
    test('There are exactly 45 puzzles', () {
      final dir = Directory('lib/features/minigames/presentation/find_differences/puzzles');
      final files = dir.listSync().where((f) => f.path.endsWith('.dart')).toList();
      expect(files.length, 45, reason: 'There must be exactly 45 puzzles');
    });
    test('Each puzzle has exactly 5 differences and unique IDs', () {
      final puzzles = [
        Puzzle01(),
        Puzzle02(),
        Puzzle03(),
        Puzzle04(),
        Puzzle05(),
        Puzzle06(),
        Puzzle07(),
        Puzzle08(),
        Puzzle09(),
        Puzzle10(),
        Puzzle11(),
        Puzzle12(),
        Puzzle13(),
        Puzzle14(),
        Puzzle15(),
        Puzzle16(),
        Puzzle17(),
        Puzzle18(),
        Puzzle19(),
        Puzzle20(),
        Puzzle21(),
        Puzzle22(),
        Puzzle23(),
        Puzzle24(),
        Puzzle25(),
        Puzzle26(),
        Puzzle27(),
        Puzzle28(),
        Puzzle29(),
        Puzzle30(),
        Puzzle31(),
        Puzzle32(),
        Puzzle33(),
        Puzzle34(),
        Puzzle35(),
        Puzzle36(),
        Puzzle37(),
        Puzzle38(),
        Puzzle39(),
        Puzzle40(),
        Puzzle41(),
        Puzzle42(),
        Puzzle43(),
        Puzzle44(),
        Puzzle45(),
      ];
      final ids = <int>{};
      for (final p in puzzles) {
        expect(p.differences.length, 5, reason: 'Puzzle must have exactly 5 differences');
        expect(ids.contains(p.id), isFalse, reason: 'Puzzle does not have a unique ID');
        ids.add(p.id);
        for (final diff in p.differences) {
          expect(diff.hitBox.left, greaterThanOrEqualTo(-50));
          expect(diff.hitBox.top, greaterThanOrEqualTo(-50));
          expect(diff.hitBox.right, lessThanOrEqualTo(1000));
          expect(diff.hitBox.bottom, lessThanOrEqualTo(1000));
        }
      }
      expect(ids.length, 45);
    });
    testWidgets('onComplete is called exactly once after finding 5 differences', (tester) async {
      int completeCount = 0;
      MiniGameResult? finalResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FindDifferencesGame(
              config: MiniGameConfig(seed: 0, difficulty: 1),
              onComplete: (r) {
                completeCount++;
                finalResult = r;
              },
            ),
          ),
        ),
      );
      final puzzle = Puzzle01();
      final boardAFinder = find.byKey(const ValueKey('find-differences-board-a'));
      expect(boardAFinder, findsOneWidget);
      final size = tester.getSize(boardAFinder);
      for (final diff in puzzle.differences) {
        final Offset logical = diff.mark;
        final dx = (logical.dx / 800) * size.width;
        final dy = (logical.dy / 600) * size.height;
        final topLeft = tester.getTopLeft(boardAFinder);
        await tester.tapAt(topLeft + Offset(dx, dy));
        await tester.pump();
      }
      final diff = puzzle.differences.last;
      final dx = (diff.mark.dx / 800) * size.width;
      final dy = (diff.mark.dy / 600) * size.height;
      final topLeft = tester.getTopLeft(boardAFinder);
      await tester.tapAt(topLeft + Offset(dx, dy));
      await tester.pump();
      expect(completeCount, 1, reason: 'onComplete should fire exactly once');
      expect(finalResult, isNotNull);
      expect(finalResult!.completed, isTrue);
      expect(finalResult!.mistakes, 0);
    });
  });
}
