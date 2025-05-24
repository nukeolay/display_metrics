import 'package:flutter/services.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// An implementation of [DisplayMetricsPlatform] that uses method channels.
class MethodChannelDisplayMetrics extends DisplayMetricsPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('display_metrics');

  @override
  Future<Size?> getSize() async {
    final nativeData =
        await methodChannel.invokeMethod<Map<Object?, Object?>>('getSize');
    return nativeData.toSize();
  }

  @override
  Future<Size?> getResolution() async {
    final nativeData = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('getResolution');
    return nativeData.toSize();
  }

  @override
  Future<List<PhysicalDisplayData>> getDisplays() async {
    final size = await getSize();
    final resolution = await getResolution();
    if (size == null || resolution == null) return const [];
    return [
      PhysicalDisplayData(
        physicalSize: size,
        resolution: resolution,
        isPrimary: true,
      ),
    ];
  }
}
