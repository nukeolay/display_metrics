import 'package:display_metrics/src/display_metrics.dart';
import 'package:flutter/widgets.dart';

extension ContextExtension on BuildContext {
  /// Converts inches to Flutter logical pixels
  double inchesToPixels(double inches) {
    final inchToPixelRatio = DisplayMetrics.of(this).inchesToLogicalPixelRatio;
    return inches * inchToPixelRatio;
  }

  /// Converts centimeters to Flutter logical pixels
  double cmToPixels(double cm) {
    final inches = cm / 2.54;
    return inchesToPixels(inches);
  }

  /// Converts Flutter logical pixels into inches
  double pixelsToInches(int pixels) {
    final inchToPixelRatio = DisplayMetrics.of(this).inchesToLogicalPixelRatio;
    return pixels / inchToPixelRatio;
  }

  /// Converts Flutter logical pixels into centimeters
  double pixelsToCm(int pixels) {
    return pixelsToInches(pixels) * 2.54;
  }
}
