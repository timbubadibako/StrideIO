import 'package:flutter/material.dart';

class StrideTypography {
  static const String metricFont = 'Space Grotesk';
  static const String bodyFont = 'Inter';

  static const TextStyle displayXL = TextStyle(
    fontFamily: metricFont,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.04 * 72,
  );

  static const TextStyle headlineLG = TextStyle(
    fontFamily: metricFont,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.02 * 40,
  );

  static const TextStyle headlineMD = TextStyle(
    fontFamily: metricFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle metricXL = TextStyle(
    fontFamily: metricFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.02 * 48,
  );

  static const TextStyle labelBold = TextStyle(
    fontFamily: metricFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.1 * 14,
  );

  static const TextStyle bodyLG = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
