import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// class that contains display metrics
class DisplayMetricsData {
  /// class that contains display metrics
  const DisplayMetricsData({required this.displays});

  /// List of all available displays metrics
  final List<ExtendedPhysicalDisplayData> displays;

  /// Display metrics data of promary display
  ExtendedPhysicalDisplayData get primaryDisplay => displays.firstWhere(
        (display) => display.isPrimary,
      );

  /// Device's primary screen physical size in inches
  Size get physicalSize => primaryDisplay.physicalSize;

  /// Device's primary screen resolution in real pixels
  Size get resolution => primaryDisplay.resolution;

  /// Device's primary screen diagonal in inches
  double get diagonal => primaryDisplay.diagonal;

  /// Device's primary screen pixels per inch (PPI)
  double get ppi => primaryDisplay.ppi;

  /// The number of logical pixels on the device's primary screen that corresponds to one inch
  double get inchesToLogicalPixelRatio =>
      primaryDisplay.inchesToLogicalPixelRatio;

  /// MediaQuery's devicePixelRatio
  double get devicePixelRatio => primaryDisplay.devicePixelRatio;

  /// Method to create updated copy of DisplayMetricsData
  DisplayMetricsData copyWith({
    List<ExtendedPhysicalDisplayData>? displays,
  }) {
    return DisplayMetricsData(
      displays: displays ?? this.displays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DisplayMetricsData) return false;
    if (runtimeType != other.runtimeType) return false;
    if (identical(displays, other.displays)) return true;
    if (displays.length != other.displays.length) return false;
    for (var i = 0; i < displays.length; i++) {
      if (displays[i] != other.displays[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => displays.fold(
        0,
        (previousValue, element) => previousValue.hashCode ^ element.hashCode,
      );
}

/// class that contains display metrics with devicePixelRatio
class ExtendedPhysicalDisplayData extends PhysicalDisplayData {
  /// class that contains display metrics with devicePixelRatio
  const ExtendedPhysicalDisplayData({
    required super.physicalSize,
    required super.resolution,
    required super.isPrimary,
    required this.devicePixelRatio,
  });

  /// creates ExtendedPhysicalDisplayData from PhysicalDisplayData
  factory ExtendedPhysicalDisplayData.fromDisplayData(
    PhysicalDisplayData data, {
    required double devicePixelRatio,
  }) {
    return ExtendedPhysicalDisplayData(
      physicalSize: data.physicalSize,
      resolution: data.resolution,
      isPrimary: data.isPrimary,
      devicePixelRatio: devicePixelRatio,
    );
  }

  /// The number of logical pixels on the device's screen that corresponds to one inch
  double get inchesToLogicalPixelRatio => ppi / devicePixelRatio;

  /// MediaQuery's devicePixelRatio;
  final double devicePixelRatio;

  /// method to create updated copy of ExtendedPhysicalDisplayData
  @override
  ExtendedPhysicalDisplayData copyWith({
    Size? physicalSize,
    Size? resolution,
    bool? isPrimary,
    double? devicePixelRatio,
  }) {
    return ExtendedPhysicalDisplayData(
      physicalSize: physicalSize ?? this.physicalSize,
      resolution: resolution ?? this.resolution,
      isPrimary: isPrimary ?? this.isPrimary,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedPhysicalDisplayData &&
          runtimeType == other.runtimeType &&
          physicalSize == other.physicalSize &&
          resolution == other.resolution &&
          isPrimary == other.isPrimary &&
          devicePixelRatio == other.devicePixelRatio;

  @override
  int get hashCode => super.hashCode ^ devicePixelRatio.hashCode;
}
