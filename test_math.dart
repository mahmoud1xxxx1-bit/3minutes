// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print
import 'dart:math' as math;
void main() {
  double maxWidth = 1920;
  double maxHeight = 1080;
  double maxW = math.max(10.0, maxWidth - 140);
  double maxH = math.max(10.0, maxHeight - 40);
  double padding = 12.0;
  int _cols = 8;
  int _rows = 7;
  double _currentTileWidth = math.min(math.max(10.0, maxW - padding*2) / _cols, math.max(10.0, maxH - padding*2) / (_rows * 1.25));
  print(_currentTileWidth);
}

