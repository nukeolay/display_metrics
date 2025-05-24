import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The Linux implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for Linux.
class DisplayMetricsLinux extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsLinux();
  }
}
