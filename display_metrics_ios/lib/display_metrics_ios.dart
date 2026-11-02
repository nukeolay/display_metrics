import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

import 'src/ios_unknown_display_info.dart';

export 'src/ios_unknown_display_info.dart';

/// The iOS implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for iOS.
class DisplayMetricsIos extends MethodChannelDisplayMetrics {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith() {
    DisplayMetricsPlatform.instance = DisplayMetricsIos();
  }

  @override
  Future<DisplaysReport> getDisplaysReport() async {
    final size = await getSize();
    final resolution = await getResolution();
    if (resolution == null) return const DisplaysReport(known: []);
    if (size != null) {
      return DisplaysReport(
        known: [
          PhysicalDisplayData(
            physicalSize: size,
            resolution: resolution,
            isPrimary: true,
          ),
        ],
      );
    }
    final modelIdentifier =
        await methodChannel.invokeMethod<String>('getModelIdentifier');
    return DisplaysReport(
      known: const [],
      unknown: [
        if (modelIdentifier == null)
          UnknownDisplayInfo(resolution: resolution, isPrimary: true)
        else
          IosUnknownDisplayInfo(
            resolution: resolution,
            isPrimary: true,
            modelIdentifier: modelIdentifier,
          ),
      ],
    );
  }
}
