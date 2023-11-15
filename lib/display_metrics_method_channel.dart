import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'display_metrics_platform_interface.dart';

/// An implementation of [DisplayMetricsPlatform] that uses method channels.
class MethodChannelDisplayMetrics extends DisplayMetricsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('display_metrics');

  @override
  Future<Size?> getSize() async {
    final size =
        await methodChannel.invokeMethod<Map<Object?, Object?>>('getSize');
    return switch (size) {
      {"Width": 0 as num, "Height": 0 as num} => null,
      {"Width": final num width, "Height": final num height} =>
        Size(width.toDouble(), height.toDouble()),
      _ => null
    };
  }

  @override
  Future<Size?> getResolution() async {
    final size = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('getResolution');
    return switch (size) {
      {"Width": 0 as num, "Height": 0 as num} => null,
      {"Width": final num width, "Height": final num height} =>
        Size(width.toDouble(), height.toDouble()),
      _ => null
    };
  }
}
