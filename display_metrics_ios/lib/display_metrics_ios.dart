import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_method_channel.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The iOS implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for iOS.
class DisplayMetricsIos extends DisplayMetricsPlatform {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = MethodChannelDisplayMetrics();
  }

  @override
  Future<Size?> getResolution() {
    return DisplayMetricsPlatform.instance.getResolution();
  }

  @override
  Future<Size?> getSize() {
    return DisplayMetricsPlatform.instance.getSize();
  }
}
