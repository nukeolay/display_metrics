import 'dart:math' as math;
import 'dart:ui';

class DisplayMetricsData {
  const DisplayMetricsData({
    required this.physicalSize,
    required this.resolution,
    required this.devicePixelRatio,
  });

  final Size physicalSize;
  final Size resolution;
  final double devicePixelRatio;

  double get diagonal =>
      _calculateDiagonal(physicalSize.width, physicalSize.height);

  double get ppi {
    final pixelDiagonal =
        _calculateDiagonal(resolution.width, resolution.height);
    return pixelDiagonal / diagonal;
  }

  double get inchesToPixelRatio => ppi / devicePixelRatio;

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
  String toString() {
    return 'ppi: $ppi, diaginal: $diagonal inches, physicalSize: ${physicalSize.width}x${physicalSize.height} inches, resolution: ${resolution.width}x${resolution.height} pixels';
  }
}
