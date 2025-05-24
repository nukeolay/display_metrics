import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The Windows implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for Windows.
class DisplayMetricsWindows extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsWindows();
  }
}
