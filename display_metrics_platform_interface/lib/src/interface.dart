import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

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

  /// Method to get primary device display size in inches
  Future<Size?> getSize();

  /// Method to get primary device display resolution in pixels
  Future<Size?> getResolution();

  /// Method to get all available display physical data
  Future<List<PhysicalDisplayData>> getDisplays();
}
