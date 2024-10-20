import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_method_channel.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

class DisplayMetricsAndroid extends DisplayMetricsPlatform {
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
