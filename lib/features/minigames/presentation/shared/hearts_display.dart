import 'package:flutter/material.dart';

class HeartsDisplay extends StatelessWidget {
  final int maxHearts;
  final int currentHearts;
  final double size;

  const HeartsDisplay({
    super.key,
    required this.maxHearts,
    required this.currentHearts,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (index) {
        bool hasHeart = index < currentHearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: hasHeart
              ? Icon(Icons.favorite, color: Colors.redAccent, size: size)
              : Icon(Icons.close, color: Colors.red, size: size),
        );
      }),
    );
  }
}
