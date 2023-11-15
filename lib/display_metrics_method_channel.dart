import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'display_metrics_platform_interface.dart';

/// An implementation of [DisplayMetricsPlatform] that uses method channels.
class MethodChannelDisplayMetrics extends DisplayMetricsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('display_metrics');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
