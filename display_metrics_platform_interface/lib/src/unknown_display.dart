import 'dart:math' as math;
import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// Display whose physical size could not be determined by the platform
///
/// Platforms report a display as unknown only when its [resolution] is known:
/// without it physical size can't be calculated from the diagonal, so such
/// display is skipped. [isPrimary] has the same meaning as in
/// [PhysicalDisplayData]: if the platform can't tell which display is primary,
/// it has to choose one the same way it does for known displays
class UnknownDisplayInfo {
  /// Display whose physical size could not be determined by the platform
  const UnknownDisplayInfo({
    required this.resolution,
    required this.isPrimary,
  });

  /// Display resolution in real pixels, always known
  final Size resolution;

  /// Will be true if this display is primary, always known
  final bool isPrimary;

  /// Creates [PhysicalDisplayData] for this display using [diagonal] in inches.
  /// Physical size keeps the aspect ratio of [resolution]
  PhysicalDisplayData toDisplayData(double diagonal) {
    final ratio = resolution.width / resolution.height;
    final height = diagonal / math.sqrt(math.pow(ratio, 2) + 1);
    final width = ratio * height;
    return PhysicalDisplayData(
      physicalSize: Size(width, height),
      resolution: resolution,
      isPrimary: isPrimary,
    );
  }

  String get _resolutionString =>
      '${resolution.width.round()}x${resolution.height.round()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDisplayInfo &&
          runtimeType == other.runtimeType &&
          resolution == other.resolution &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode => resolution.hashCode ^ isPrimary.hashCode;

  @override
  String toString() => 'unknown display (resolution: $_resolutionString)';
}

/// Result of displays request that includes displays with unknown size
class DisplaysReport {
  /// Result of displays request that includes displays with unknown size
  const DisplaysReport({
    required this.known,
    this.unknown = const [],
  });

  /// Displays with known physical size
  final List<PhysicalDisplayData> known;

  /// Displays whose physical size could not be determined
  final List<UnknownDisplayInfo> unknown;
}
