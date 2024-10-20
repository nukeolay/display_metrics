import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_method_channel.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// An implementation of [DisplayMetricsPlatform] that uses method channels.
class DisplayMetricsAndroid extends DisplayMetricsPlatform {
  /// The method channel used to interact with the native platform.
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
