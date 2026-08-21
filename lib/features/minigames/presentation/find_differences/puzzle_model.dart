import 'package:flutter/material.dart';
import 'html_canvas.dart';

class Difference {
  final String id;
  final Rect hitBox;
  final Offset mark;
  final void Function(HtmlCanvas c) draw;

  Difference(this.id, this.hitBox, this.mark, this.draw);
}

abstract class PuzzleDefinition {
  int get id;
  void drawBaseScene(HtmlCanvas c);
  List<Difference> get differences;
}
