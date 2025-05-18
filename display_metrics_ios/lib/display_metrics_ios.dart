import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The iOS implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for iOS.
class DisplayMetricsIos extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsIos();
  }
}
