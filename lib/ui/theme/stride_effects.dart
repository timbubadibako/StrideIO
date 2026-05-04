import 'package:flutter/material.dart';
import 'stride_colors.dart';

class StrideEffects {
  static List<BoxShadow> neonGlow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }

  static BoxDecoration glassCardDecoration() {
    return BoxDecoration(
      color: StrideColors.surfaceContainer.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16), // Using logic from radii
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    );
  }
}
