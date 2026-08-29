import 'package:flutter/material.dart';

class MinigameEnvironment extends InheritedWidget {
  const MinigameEnvironment({
    super.key,
    required this.onScore,
    required this.onTimeProgress,
    required this.onSuccess,
    required this.onError,
    required super.child,
  });

  final ValueChanged<int> onScore;
  final ValueChanged<double> onTimeProgress;
  final ValueChanged<Offset> onSuccess;
  final ValueChanged<Offset> onError;

  static MinigameEnvironment of(BuildContext context) {
    final value = context.dependOnInheritedWidgetOfExactType<MinigameEnvironment>();
    assert(value != null, 'MinigameEnvironment is missing.');
    return value!;
  }

  void updateScore(int score) => onScore(score);
  void updateTimeProgress(double progress) => onTimeProgress(progress);
  void playSuccess(Offset position) => onSuccess(position);
  void playError(Offset position) => onError(position);

  @override
  bool updateShouldNotify(covariant MinigameEnvironment oldWidget) => false;
}
