import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// class that contains physical display metrics
class PhysicalDisplayData {
  /// class that contains physical display metrics
  const PhysicalDisplayData({
    required this.physicalSize,
    required this.resolution,
    required this.isPrimary,
  });

  /// Device's screen physical size in inches
  final Size physicalSize;

  /// Device's screen resolution in real pixels
  final Size resolution;

  /// Will be true if this display is primary
  final bool isPrimary;

  /// Device's screen diagonal in inches
  double get diagonal =>
      _calculateDiagonal(physicalSize.width, physicalSize.height);

  /// Device's screen pixels per inch (PPI)
  double get ppi {
    final pixelDiagonal =
        _calculateDiagonal(resolution.width, resolution.height);
    return pixelDiagonal / diagonal;
  }

  double _calculateDiagonal(double width, double height) => math.sqrt(
        math.pow(width, 2) + math.pow(height, 2),
      );

  /// method to create updated copy of PhysicalDisplayData
  PhysicalDisplayData copyWith({
    Size? physicalSize,
    Size? resolution,
    bool? isPrimary,
  }) {
    return PhysicalDisplayData(
      physicalSize: physicalSize ?? this.physicalSize,
      resolution: resolution ?? this.resolution,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalDisplayData &&
          runtimeType == other.runtimeType &&
          physicalSize == other.physicalSize &&
          resolution == other.resolution &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      physicalSize.hashCode ^ resolution.hashCode ^ isPrimary.hashCode;

  @override
  String toString() => 'ppi: $ppi, '
      'diagonal: $diagonal inches, '
      'physicalSize: ${physicalSize.width}x${physicalSize.height} inches, '
      'resolution: ${resolution.width}x${resolution.height} pixels, '
      'isPrimary: $isPrimary';
}
