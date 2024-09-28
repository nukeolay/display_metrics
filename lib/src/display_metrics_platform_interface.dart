import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:display_metrics/src/display_metrics_method_channel.dart';

abstract class DisplayMetricsPlatform extends PlatformInterface {
  /// Constructs a DisplayMetricsPlatform.
  DisplayMetricsPlatform() : super(token: _token);

  static final Object _token = Object();

  static DisplayMetricsPlatform _instance = MethodChannelDisplayMetrics();

  /// The default instance of [DisplayMetricsPlatform] to use.
  ///
  /// Defaults to [MethodChannelDisplayMetrics].
  static DisplayMetricsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DisplayMetricsPlatform] when
  /// they register themselves.
  static set instance(DisplayMetricsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Size?> getSize();

  Future<Size?> getResolution();
}
