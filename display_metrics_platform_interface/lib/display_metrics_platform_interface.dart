library display_metrics_platform_interface;

import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of display_metrics must implement.
///
/// Platform implementations should extend this class rather than implement it as `display_metrics`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [DisplayMetricsPlatform] methods.
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
