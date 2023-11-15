import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/widgets.dart';

extension ContextExtension on BuildContext {
  double inchesToPixels(double inches) {
    final inchToPixelRatio = DisplayMetrics.of(this).inchesToPixelRatio;
    return inches * inchToPixelRatio;
  }

  double cmToPixels(double cm) {
    final inches = cm / 2.54;
    return inchesToPixels(inches);
  }

  double pixelsToInches(int pixels) {
    final inchToPixelRatio = DisplayMetrics.of(this).inchesToPixelRatio;
    return pixels / inchToPixelRatio;
  }

  double pixelsToCm(int pixels) {
    return pixelsToInches(pixels) * 2.54;
  }
}
