import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The macOS implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for macOS.
class DisplayMetricsMacos extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsMacos();
  }
}
