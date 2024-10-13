import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
      {'width': 0, 'height': 0} => null,
      {'width': final num width, 'height': final num height} =>
        Size(width.toDouble(), height.toDouble()),
      _ => null
    };
  }

  @override
  Future<Size?> getResolution() async {
    final size = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('getResolution');
    return switch (size) {
      {'width': 0, 'height': 0} => null,
      {'width': final num width, 'height': final num height} =>
        Size(width.toDouble(), height.toDouble()),
      _ => null
    };
  }
}
