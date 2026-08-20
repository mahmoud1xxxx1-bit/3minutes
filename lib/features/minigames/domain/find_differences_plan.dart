import '../../../core/random/deterministic_rng.dart';

enum FindDifferenceShape { circle, rect, polygon }

class FindDifferencePoint {
  const FindDifferencePoint(this.x, this.y);

  final double x;
  final double y;
}

class FindDifference {
  const FindDifference._({
    required this.id,
    required this.shape,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.points,
  });

  const FindDifference.circle({
    required String id,
    required double centerX,
    required double centerY,
    required double radius,
  }) : this._(
          id: id,
          shape: FindDifferenceShape.circle,
          x: centerX - radius,
          y: centerY - radius,
          width: radius * 2,
          height: radius * 2,
          points: const [],
        );

  const FindDifference.rect({
    required String id,
    required double x,
    required double y,
    required double width,
    required double height,
  }) : this._(
          id: id,
          shape: FindDifferenceShape.rect,
          x: x,
          y: y,
          width: width,
          height: height,
          points: const [],
        );

  const FindDifference.polygon({
    required String id,
    required List<FindDifferencePoint> points,
  }) : this._(
          id: id,
          shape: FindDifferenceShape.polygon,
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          points: points,
        );

  final String id;
  final FindDifferenceShape shape;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<FindDifferencePoint> points;

  double get centerX {
    if (shape != FindDifferenceShape.polygon) return x + width / 2;
    return points.fold<double>(0, (sum, p) => sum + p.x) / points.length;
  }

  double get centerY {
    if (shape != FindDifferenceShape.polygon) return y + height / 2;
    return points.fold<double>(0, (sum, p) => sum + p.y) / points.length;
  }

  bool contains(double logicalX, double logicalY) {
    switch (shape) {
      case FindDifferenceShape.circle:
        final dx = logicalX - centerX;
        final dy = logicalY - centerY;
        final radius = width / 2;
        return dx * dx + dy * dy <= radius * radius;
      case FindDifferenceShape.rect:
        return logicalX >= x &&
            logicalX <= x + width &&
            logicalY >= y &&
            logicalY <= y + height;
      case FindDifferenceShape.polygon:
        var inside = false;
        for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
          final pi = points[i];
          final pj = points[j];
          final crosses = (pi.y > logicalY) != (pj.y > logicalY);
          if (!crosses) continue;
          final intersectX = (pj.x - pi.x) * (logicalY - pi.y) /
                  (pj.y - pi.y) +
              pi.x;
          if (logicalX < intersectX) inside = !inside;
        }
        return inside;
    }
  }
}

class FindDifferencesPlan {
  const FindDifferencesPlan({
    required this.variantIndex,
    required this.differences,
    required this.duration,
  });

  static const double logicalWidth = 800;
  static const double logicalHeight = 600;
  static const int variantCount = 12;

  final int variantIndex;
  final List<FindDifference> differences;
  final Duration duration;

  static const Map<String, FindDifference> catalog = {
    'clock_time': FindDifference.polygon(
      id: 'clock_time',
      points: [
        FindDifferencePoint(616, 114),
        FindDifferencePoint(620, 114),
        FindDifferencePoint(653, 88),
        FindDifferencePoint(657, 92),
        FindDifferencePoint(624, 122),
        FindDifferencePoint(618, 121),
      ],
    ),
    'moon_missing': FindDifference.circle(
      id: 'moon_missing', centerX: 110, centerY: 103, radius: 28),
    'moon_color': FindDifference.circle(
      id: 'moon_color', centerX: 110, centerY: 103, radius: 28),
    'painting_detail': FindDifference.circle(
      id: 'painting_detail', centerX: 430, centerY: 115, radius: 24),
    'painting_peak': FindDifference.polygon(
      id: 'painting_peak',
      points: [
        FindDifferencePoint(452, 151),
        FindDifferencePoint(466, 125),
        FindDifferencePoint(480, 151),
      ],
    ),
    'book_missing': FindDifference.rect(
      id: 'book_missing', x: 640, y: 148, width: 22, height: 62),
    'book_short': FindDifference.rect(
      id: 'book_short', x: 670, y: 166, width: 22, height: 44),
    'book_color': FindDifference.rect(
      id: 'book_color', x: 610, y: 160, width: 22, height: 50),
    'lamp_shade': FindDifference.polygon(
      id: 'lamp_shade',
      points: [
        FindDifferencePoint(650, 265),
        FindDifferencePoint(750, 265),
        FindDifferencePoint(730, 325),
        FindDifferencePoint(670, 325),
      ],
    ),
    'lamp_stem': FindDifference.rect(
      id: 'lamp_stem', x: 696, y: 330, width: 8, height: 74),
    'cushion_left': FindDifference.rect(
      id: 'cushion_left', x: 235, y: 355, width: 90, height: 75),
    'cushion_middle': FindDifference.rect(
      id: 'cushion_middle', x: 342, y: 363, width: 90, height: 67),
    'cushion_right': FindDifference.rect(
      id: 'cushion_right', x: 450, y: 356, width: 88, height: 74),
    'mug_color': FindDifference.rect(
      id: 'mug_color', x: 270, y: 430, width: 62, height: 58),
    'mug_handle': FindDifference.circle(
      id: 'mug_handle', centerX: 328, centerY: 458, radius: 23),
    'fruit_missing': FindDifference.circle(
      id: 'fruit_missing', centerX: 500, centerY: 453, radius: 18),
    'fruit_color': FindDifference.circle(
      id: 'fruit_color', centerX: 440, centerY: 447, radius: 18),
    'fruit_color_2': FindDifference.circle(
      id: 'fruit_color_2', centerX: 470, centerY: 450, radius: 18),
    'plant_pot': FindDifference.rect(
      id: 'plant_pot', x: 70, y: 395, width: 90, height: 95),
    'plant_leaf': FindDifference.circle(
      id: 'plant_leaf', centerX: 85, centerY: 300, radius: 22),
    'table_top': FindDifference.rect(
      id: 'table_top', x: 250, y: 480, width: 360, height: 34),
    'table_leg': FindDifference.rect(
      id: 'table_leg', x: 555, y: 510, width: 20, height: 80),
  };

  static const List<List<String>> variants = [
    ['clock_time', 'painting_detail', 'book_missing', 'lamp_shade', 'cushion_left'],
    ['moon_missing', 'painting_peak', 'book_color', 'cushion_middle', 'fruit_missing'],
    ['moon_color', 'book_short', 'lamp_stem', 'cushion_right', 'plant_leaf'],
    ['clock_time', 'painting_peak', 'cushion_left', 'mug_handle', 'fruit_color'],
    ['moon_missing', 'painting_detail', 'book_color', 'cushion_right', 'plant_pot'],
    ['moon_color', 'book_missing', 'lamp_shade', 'cushion_middle', 'fruit_color_2'],
    ['clock_time', 'book_short', 'lamp_stem', 'cushion_left', 'table_top'],
    ['moon_missing', 'painting_peak', 'cushion_middle', 'mug_color', 'plant_leaf'],
    ['painting_detail', 'book_color', 'cushion_right', 'fruit_missing', 'plant_pot'],
    ['moon_color', 'book_missing', 'cushion_left', 'mug_handle', 'table_leg'],
    ['clock_time', 'painting_peak', 'book_short', 'cushion_middle', 'fruit_color'],
    ['moon_missing', 'painting_detail', 'lamp_shade', 'cushion_right', 'fruit_color_2'],
  ];

  static FindDifferencesPlan fromSeed({
    required int seed,
    required int difficulty,
  }) {
    final random = DeterministicRng(seed & 0xffffffff);
    final variantIndex = random.nextInt(variantCount);
    final targetCount = difficulty >= 2 ? 5 : difficulty == 1 ? 4 : 3;
    final ids = variants[variantIndex];
    final differences = ids
        .take(targetCount)
        .map((id) => catalog[id]!)
        .toList(growable: false);
    final duration = Duration(seconds: difficulty >= 2 ? 18 : difficulty == 1 ? 20 : 22);
    return FindDifferencesPlan(
      variantIndex: variantIndex,
      differences: List.unmodifiable(differences),
      duration: duration,
    );
  }

  FindDifference? hitTest(double logicalX, double logicalY, Set<String> found) {
    if (logicalX < 0 ||
        logicalX > logicalWidth ||
        logicalY < 0 ||
        logicalY > logicalHeight) {
      return null;
    }
    for (final difference in differences) {
      if (!found.contains(difference.id) && difference.contains(logicalX, logicalY)) {
        return difference;
      }
    }
    return null;
  }
}
