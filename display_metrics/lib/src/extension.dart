import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';

/// BuildContext extension that provides essential display_metrics methods
extension ContextExtension on BuildContext {
  /// Converts inches to Flutter logical pixels
  double inchesToPixels(double inches) {
    final inchToPixelRatio = DisplayMetrics.of(this).inchesToLogicalPixelRatio;
    return inches * inchToPixelRatio;
  }

  /// Converts millimeters to Flutter logical pixels
  double mmToPixels(double mm) {
    final inches = mm / 25.4;
    return inchesToPixels(inches);
  }

  @Deprecated('Use mmToPixels(mm) instead')

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

  /// Converts Flutter logical pixels into millimeters
  double pixelsToMm(int pixels) {
    return pixelsToInches(pixels) * 25.4;
  }

  @Deprecated('Use pixelsToMm(pixels) instead')

  /// Converts Flutter logical pixels into centimeters
  double pixelsToCm(int pixels) {
    return pixelsToInches(pixels) * 2.54;
  }
}

/// Size extension
extension SizeExtension on Size {
  /// Returns a [Size] with the width and height swapped for [Orientation]
  Size byOrientation(Orientation? orientation) {
    if (orientation == null) return this;
    switch (orientation) {
      case Orientation.portrait:
        return Size(shortestSide, longestSide);
      case Orientation.landscape:
        return Size(longestSide, shortestSide);
    }
  }
}
