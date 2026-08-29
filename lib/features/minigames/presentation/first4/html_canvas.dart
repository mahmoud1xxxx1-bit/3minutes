import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CanvasGradient {
  final ui.Gradient shader;
  CanvasGradient(this.shader);
  void addColorStop(double offset, String color) {
    // We would need to rebuild the shader, which is tricky in Dart since ui.Gradient requires all colors at once.
    // In our JS, we almost always chain addColorStop immediately.
  }
}

// We will implement a smart gradient builder
class GradientBuilder {
  final double x0, y0, x1, y1;
  final double? r0, r1;
  final bool isRadial;
  List<double> stops = [];
  List<Color> colors = [];
  
  GradientBuilder.linear(this.x0, this.y0, this.x1, this.y1) : isRadial = false, r0 = null, r1 = null;
  GradientBuilder.radial(this.x0, this.y0, this.r0, this.x1, this.y1, this.r1) : isRadial = true;

  void addColorStop(double offset, String colorStr) {
    stops.add(offset);
    colors.add(HtmlCanvas.parseColor(colorStr));
  }

  ui.Shader build() {
    if (isRadial) {
      return ui.Gradient.radial(Offset(x1, y1), r1 ?? 0, colors, stops);
    } else {
      return ui.Gradient.linear(Offset(x0, y0), Offset(x1, y1), colors, stops);
    }
  }
}

class CanvasState {
  Paint fillPaint;
  Paint strokePaint;
  double globalAlpha;
  double shadowBlur;
  Color shadowColor;
  CanvasState(this.fillPaint, this.strokePaint, this.globalAlpha, this.shadowBlur, this.shadowColor);
  
  CanvasState clone() {
    return CanvasState(
      Paint()..color = fillPaint.color..style = fillPaint.style..shader = fillPaint.shader,
      Paint()..color = strokePaint.color..style = strokePaint.style..strokeWidth = strokePaint.strokeWidth..strokeCap = strokePaint.strokeCap..strokeJoin = strokePaint.strokeJoin,
      globalAlpha,
      shadowBlur,
      shadowColor,
    );
  }
}

class HtmlCanvas {
  final Canvas canvas;
  final Size size;
  
  Paint _fillPaint = Paint()..style = PaintingStyle.fill..color = Colors.black;
  Paint _strokePaint = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1.0;
  Path _currentPath = Path();
  
  double globalAlpha = 1.0;
  Color _shadowColor = Colors.transparent;
  set shadowColor(dynamic value) {
    if (value is String) _shadowColor = parseColor(value);
    else if (value is Color) _shadowColor = value;
  }
  Color get shadowColor => _shadowColor;
  double shadowBlur = 0.0;
  String font = '10px sans-serif';
  String textAlign = 'left';
  String textBaseline = 'top';
  
  final List<CanvasState> _stateStack = [];

  HtmlCanvas(this.canvas, this.size);

  static Color parseColor(String c) {
    c = c.trim();
    if (c.startsWith('#')) {
      c = c.substring(1);
      if (c.length == 3) {
        c = c[0]+c[0]+c[1]+c[1]+c[2]+c[2];
      }
      if (c.length == 6) {
        return Color(int.parse('FF$c', radix: 16));
      } else if (c.length == 8) {
        final r = c.substring(0,2);
        final g = c.substring(2,4);
        final b = c.substring(4,6);
        final a = c.substring(6,8);
        return Color(int.parse(a + r + g + b, radix: 16));
      }
    } else if (c.startsWith('rgba')) {
      final reg = RegExp(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d\.]+)\s*\)');
      final match = reg.firstMatch(c);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final a = double.parse(match.group(4)!);
        return Color.fromARGB((a * 255).toInt(), r, g, b);
      }
    } else if (c.startsWith('rgb')) {
      final reg = RegExp(r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
      final match = reg.firstMatch(c);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        return Color.fromARGB(255, r, g, b);
      }
    }
    return Colors.black;
  }

  set fillStyle(dynamic value) {
    if (value is String) {
      _fillPaint.shader = null;
      final parsed = parseColor(value);
      _fillPaint.color = parsed.withAlpha((parsed.alpha * globalAlpha).toInt());
    } else if (value is GradientBuilder) {
      _fillPaint.shader = value.build();
    }
  }

  set strokeStyle(dynamic value) {
    if (value is String) {
      _strokePaint.shader = null;
      final parsed = parseColor(value);
      _strokePaint.color = parsed.withAlpha((parsed.alpha * globalAlpha).toInt());
    } else if (value is GradientBuilder) {
      _strokePaint.shader = value.build();
    }
  }

  set lineWidth(double w) { _strokePaint.strokeWidth = w; }
  
  set lineCap(String cap) {
    if (cap == 'round') _strokePaint.strokeCap = StrokeCap.round;
    else if (cap == 'square') _strokePaint.strokeCap = StrokeCap.square;
    else _strokePaint.strokeCap = StrokeCap.butt;
  }
  
  set lineJoin(String join) {
    if (join == 'round') _strokePaint.strokeJoin = StrokeJoin.round;
    else if (join == 'bevel') _strokePaint.strokeJoin = StrokeJoin.bevel;
    else _strokePaint.strokeJoin = StrokeJoin.miter;
  }

  CanvasState get currentState => CanvasState(_fillPaint, _strokePaint, globalAlpha, shadowBlur, shadowColor);
  void save() {
    canvas.save();
    _stateStack.add(currentState.clone());
  }

  void restore() {
    if (_stateStack.isNotEmpty) {
      canvas.restore();
      final state = _stateStack.removeLast();
      _fillPaint = state.fillPaint;
      _strokePaint = state.strokePaint;
      globalAlpha = state.globalAlpha;
      shadowBlur = state.shadowBlur;
      _shadowColor = state.shadowColor;
    }
  }

  void scale(num x, num y) { canvas.scale(x.toDouble(), y.toDouble()); }
  void translate(num x, num y) { canvas.translate(x.toDouble(), y.toDouble()); }
  void rotate(num a) { canvas.rotate(a.toDouble()); }
  
  GradientBuilder createLinearGradient(num x0, num y0, num x1, num y1) {
    return GradientBuilder.linear(x0.toDouble(), y0.toDouble(), x1.toDouble(), y1.toDouble());
  }
  GradientBuilder createRadialGradient(num x0, num y0, num r0, num x1, num y1, num r1) {
    return GradientBuilder.radial(x0.toDouble(), y0.toDouble(), r0.toDouble(), x1.toDouble(), y1.toDouble(), r1.toDouble());
  }

  void setLineDash(List<num> dash) {}

  void fillText(String text, num x, num y) {
    double fontSize = 20.0;
    if (font.contains('px')) {
      final match = RegExp(r'(\d+)px').firstMatch(font);
      if (match != null) fontSize = double.parse(match.group(1)!);
    }
    final span = TextSpan(
      style: TextStyle(
        color: _fillPaint.color,
        fontSize: fontSize,
        fontWeight: font.contains('bold') ? FontWeight.bold : FontWeight.normal,
      ),
      text: text,
    );
    final tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    double dx = x.toDouble();
    double dy = y.toDouble();
    if (textAlign == 'center') dx -= tp.width / 2;
    else if (textAlign == 'right') dx -= tp.width;
    if (textBaseline == 'middle') dy -= tp.height / 2;
    else if (textBaseline == 'bottom') dy -= tp.height;
    tp.paint(canvas, Offset(dx, dy));
  }

  void beginPath() { _currentPath = Path(); }
  void closePath() { _currentPath.close(); }
  void moveTo(num x, num y) { _currentPath.moveTo(x.toDouble(), y.toDouble()); }
  void lineTo(num x, num y) { _currentPath.lineTo(x.toDouble(), y.toDouble()); }
  void quadraticCurveTo(num cpx, num cpy, num x, num y) { _currentPath.quadraticBezierTo(cpx.toDouble(), cpy.toDouble(), x.toDouble(), y.toDouble()); }
  void bezierCurveTo(num c1x, num c1y, num c2x, num c2y, num x, num y) { _currentPath.cubicTo(c1x.toDouble(), c1y.toDouble(), c2x.toDouble(), c2y.toDouble(), x.toDouble(), y.toDouble()); }
  void arc(num x, num y, num r, num sA, num eA) { _currentPath.addArc(Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: r.toDouble()), sA.toDouble(), eA.toDouble() - sA.toDouble()); }
  void ellipse(num x, num y, num rx, num ry, num rot, num sA, num eA) { _currentPath.addArc(Rect.fromCenter(center: Offset(x.toDouble(), y.toDouble()), width: rx.toDouble()*2, height: ry.toDouble()*2), sA.toDouble(), eA.toDouble() - sA.toDouble()); }
  void fill() { canvas.drawPath(_currentPath, _fillPaint); }
  void stroke() { canvas.drawPath(_currentPath, _strokePaint); }

  void fillRect(num x, num y, num w, num h) {
    canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), _fillPaint);
  }

  void strokeRect(num x, num y, num w, num h) {
    canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), _strokePaint);
  }

  void roundRect(num x, num y, num w, num h, dynamic r) {
    double rad = 0.0;
    if (r is num) rad = r.toDouble();
    else if (r is List && r.isNotEmpty) rad = r[0].toDouble();
    _currentPath.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), Radius.circular(rad)));
  }
}
