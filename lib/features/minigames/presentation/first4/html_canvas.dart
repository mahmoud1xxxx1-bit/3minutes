import 'package:flutter/material.dart';

class HtmlCanvas {
  HtmlCanvas(this.canvas, this.size);

  final Canvas canvas;
  final Size size;
  Paint _fillPaint = Paint()..style = PaintingStyle.fill..color = Colors.black;
  Paint _strokePaint = Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1;
  Path _path = Path();

  static Color parseColor(String value) {
    var c = value.trim();
    if (c.startsWith('#')) {
      c = c.substring(1);
      if (c.length == 3) c = '${c[0]}${c[0]}${c[1]}${c[1]}${c[2]}${c[2]}';
      if (c.length == 6) return Color(int.parse('FF$c', radix: 16));
    }
    return Colors.black;
  }

  set fillStyle(String value) => _fillPaint = Paint()..style = PaintingStyle.fill..color = parseColor(value);
  set strokeStyle(String value) => _strokePaint = Paint()..style = PaintingStyle.stroke..color = parseColor(value)..strokeWidth = _strokePaint.strokeWidth;
  set lineWidth(num value) => _strokePaint.strokeWidth = value.toDouble();

  void save() => canvas.save();
  void restore() => canvas.restore();
  void scale(num x, num y) => canvas.scale(x.toDouble(), y.toDouble());
  void beginPath() => _path = Path();
  void moveTo(num x, num y) => _path.moveTo(x.toDouble(), y.toDouble());
  void lineTo(num x, num y) => _path.lineTo(x.toDouble(), y.toDouble());
  void quadraticCurveTo(num cx, num cy, num x, num y) => _path.quadraticBezierTo(cx.toDouble(), cy.toDouble(), x.toDouble(), y.toDouble());
  void arc(num x, num y, num r, num start, num end) => _path.addArc(Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: r.toDouble()), start.toDouble(), end.toDouble() - start.toDouble());
  void ellipse(num x, num y, num rx, num ry, num rotation, num start, num end) => _path.addArc(Rect.fromCenter(center: Offset(x.toDouble(), y.toDouble()), width: rx.toDouble() * 2, height: ry.toDouble() * 2), start.toDouble(), end.toDouble() - start.toDouble());
  void roundRect(num x, num y, num w, num h, num radius) => _path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), Radius.circular(radius.toDouble())));
  void fill() => canvas.drawPath(_path, _fillPaint);
  void stroke() => canvas.drawPath(_path, _strokePaint);
  void fillRect(num x, num y, num w, num h) => canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), _fillPaint);
  void strokeRect(num x, num y, num w, num h) => canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()), _strokePaint);
}
