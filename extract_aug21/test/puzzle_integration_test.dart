import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_differences/main.dart';
import 'package:find_differences/puzzle_model.dart';
import 'package:find_differences/puzzles/puzzle_01.dart';
import 'package:find_differences/puzzles/puzzle_02.dart';
import 'package:find_differences/puzzles/puzzle_03.dart';
import 'package:find_differences/puzzles/puzzle_04.dart';
import 'package:find_differences/puzzles/puzzle_05.dart';
import 'package:find_differences/puzzles/puzzle_06.dart';
import 'package:find_differences/puzzles/puzzle_07.dart';
import 'package:find_differences/puzzles/puzzle_08.dart';
import 'package:find_differences/puzzles/puzzle_09.dart';
import 'package:find_differences/puzzles/puzzle_10.dart';
import 'package:find_differences/puzzles/puzzle_11.dart';
import 'package:find_differences/puzzles/puzzle_12.dart';
import 'package:find_differences/puzzles/puzzle_13.dart';
import 'package:find_differences/puzzles/puzzle_14.dart';
import 'package:find_differences/puzzles/puzzle_15.dart';
import 'package:find_differences/puzzles/puzzle_16.dart';
import 'package:find_differences/puzzles/puzzle_17.dart';
import 'package:find_differences/puzzles/puzzle_18.dart';
import 'package:find_differences/puzzles/puzzle_19.dart';
import 'package:find_differences/puzzles/puzzle_20.dart';
import 'package:find_differences/puzzles/puzzle_21.dart';
import 'package:find_differences/puzzles/puzzle_22.dart';
import 'package:find_differences/puzzles/puzzle_23.dart';
import 'package:find_differences/puzzles/puzzle_24.dart';
import 'package:find_differences/puzzles/puzzle_25.dart';
import 'package:find_differences/puzzles/puzzle_26.dart';
import 'package:find_differences/puzzles/puzzle_27.dart';
import 'package:find_differences/puzzles/puzzle_28.dart';
import 'package:find_differences/puzzles/puzzle_29.dart';
import 'package:find_differences/puzzles/puzzle_30.dart';
import 'package:find_differences/puzzles/puzzle_31.dart';
import 'package:find_differences/puzzles/puzzle_32.dart';
import 'package:find_differences/puzzles/puzzle_33.dart';
import 'package:find_differences/puzzles/puzzle_34.dart';
import 'package:find_differences/puzzles/puzzle_35.dart';

final List<PuzzleDefinition> puzzles = [
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
    Puzzle30()
  ];

void main() {
  testWidgets('Test all 35 puzzles for exactly 5 differences and complete gameplay', (WidgetTester tester) async {
    await tester.pumpWidget(const SpotTheDifferenceApp());
    await tester.pumpAndSettle();

    for (int i = 0; i < puzzles.length; i++) {
      PuzzleDefinition puzzle = puzzles[i];
      final boardBFinder = find.byKey(const Key('boardB'));
      final RenderBox box = tester.renderObject(boardBFinder);
      final Size boardSize = box.size;
      final double scaleX = boardSize.width / 800.0;
      final double scaleY = boardSize.height / 600.0;

      for (int diffIndex = 0; diffIndex < puzzle.differences.length; diffIndex++) {
        Difference diff = puzzle.differences[diffIndex];
        Offset actualTapOffset = Offset(diff.mark.dx * scaleX, diff.mark.dy * scaleY);
        await tester.tapAt(box.localToGlobal(actualTapOffset));
        await tester.pumpAndSettle();
      }

      await tester.pump(const Duration(seconds: 1));
      final nextRoundBtn = find.byKey(const Key('next_round'));
      expect(nextRoundBtn, findsOneWidget, reason: 'Win dialog did not appear for Puzzle ' + puzzle.id.toString());
      if (i < puzzles.length - 1) {
        await tester.tap(nextRoundBtn);
        await tester.pumpAndSettle();
      }
    }
  });
}
