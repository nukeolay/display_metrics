import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

export 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The Android implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for Android.
class DisplayMetricsAndroid extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsAndroid();
  }

  @override
  Future<List<PhysicalDisplayData>> getDisplays() async {
    final displays =
        (await methodChannel.invokeMethod<List<Object?>>('getDisplays'))
            ?.nonNulls;
    if (displays == null || displays.isEmpty) return const [];
    final result = <PhysicalDisplayData>[];
    for (final display in displays) {
      final data = _parseDisplay(display);
      if (data == null) continue;
      result.add(data);
    }
    return result;
  }

  PhysicalDisplayData? _parseDisplay(Object? display) {
    switch (display) {
      case {
          'size': Map sizeMap,
          'resolution': Map resolutionMap,
          'isPrimary': bool isPrimary,
        }:
        final size = sizeMap.toSize();
        final resolution = resolutionMap.toSize();
        if (size == null || resolution == null) return null;
        return PhysicalDisplayData(
          physicalSize: size,
          resolution: resolution,
          isPrimary: isPrimary,
        );
      default:
        return null;
    }
  }
}
