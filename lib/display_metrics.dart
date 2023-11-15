
import 'display_metrics_platform_interface.dart';

class DisplayMetrics {
  Future<String?> getPlatformVersion() {
    return DisplayMetricsPlatform.instance.getPlatformVersion();
  }
}
