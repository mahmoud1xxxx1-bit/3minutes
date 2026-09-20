import 'package:flutter/material.dart';
import 'dart:async';

class MinigameFeedbackEvent {
  final Offset position;
  final bool isSuccess;
  MinigameFeedbackEvent(this.position, this.isSuccess);
}

class MinigameEnvironmentController extends ChangeNotifier {
  int _score = 0;
  int _combo = 0;
  double _timeProgress = 0.0;
  String _title = "";

  int get score => _score;
  int get combo => _combo;
  double get timeProgress => _timeProgress;
  String get title => _title;

  final StreamController<MinigameFeedbackEvent> _feedbackController = StreamController.broadcast();
  Stream<MinigameFeedbackEvent> get feedbackStream => _feedbackController.stream;

  void setTitle(String newTitle) {
    if (_title != newTitle) {
      _title = newTitle;
      notifyListeners();
    }
  }

  void updateScore(int newScore, {int newCombo = 0}) {
    if (_score != newScore || _combo != newCombo) {
      _score = newScore;
      _combo = newCombo;
      notifyListeners();
    }
  }

  void updateTimeProgress(double progress) {
    if (_timeProgress != progress) {
      _timeProgress = progress;
      notifyListeners();
    }
  }

  void playSuccess(Offset position) {
    _feedbackController.add(MinigameFeedbackEvent(position, true));
  }

  void playError(Offset position) {
    _feedbackController.add(MinigameFeedbackEvent(position, false));
  }

  @override
  void dispose() {
    _feedbackController.close();
    super.dispose();
  }
}

class MinigameEnvironment extends InheritedWidget {
  final MinigameEnvironmentController controller;

  const MinigameEnvironment({
    super.key,
    required this.controller,
    required super.child,
  });

  static MinigameEnvironmentController of(BuildContext context) {
    final MinigameEnvironment? result = context.dependOnInheritedWidgetOfExactType<MinigameEnvironment>();
    assert(result != null, 'No MinigameEnvironment found in context');
    return result!.controller;
  }

  @override
  bool updateShouldNotify(MinigameEnvironment oldWidget) {
    return oldWidget.controller != controller;
  }
}
