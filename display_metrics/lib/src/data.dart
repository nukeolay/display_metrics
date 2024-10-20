import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

class DisplayMetricsData {
  const DisplayMetricsData({
    required this.physicalSize,
    required this.resolution,
    required this.devicePixelRatio,
  });

  /// Device's screen physical size in inches
  final Size physicalSize;

  /// Device's screen resolution in real pixels
  final Size resolution;

  /// Device's screen diagonal in inches
  double get diagonal =>
      _calculateDiagonal(physicalSize.width, physicalSize.height);

  /// Device's screen pixels per inch (PPI)
  double get ppi {
    final pixelDiagonal =
        _calculateDiagonal(resolution.width, resolution.height);
    return pixelDiagonal / diagonal;
  }

  /// The number of logical pixels on the device's screen that corresponds to one inch
  double get inchesToLogicalPixelRatio => ppi / devicePixelRatio;

  /// MediaQuery's devicePixelRatio;
  final double devicePixelRatio;

  double _calculateDiagonal(double width, double height) => math.sqrt(
        math.pow(width, 2) + math.pow(height, 2),
      );

  DisplayMetricsData copyWith({
    Size? physicalSize,
    Size? resolution,
    double? devicePixelRatio,
  }) {
    return DisplayMetricsData(
      physicalSize: physicalSize ?? this.physicalSize,
      resolution: resolution ?? this.resolution,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayMetricsData &&
          runtimeType == other.runtimeType &&
          physicalSize == other.physicalSize &&
          resolution == other.resolution &&
          devicePixelRatio == other.devicePixelRatio;

  @override
  int get hashCode => physicalSize.hashCode ^ resolution.hashCode;

  @override
  String toString() => 'ppi: $ppi, '
      'diagonal: $diagonal inches, '
      'physicalSize: ${physicalSize.width}x${physicalSize.height} inches, '
      'resolution: ${resolution.width}x${resolution.height} pixels';
}
