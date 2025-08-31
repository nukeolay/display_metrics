import 'dart:ui';

import 'package:web/web.dart' as web;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// The Web implementation of [DisplayMetricsPlatform].
///
/// This class implements the `package:display_metrics` functionality for Web.
class DisplayMetricsPlugin extends DisplayMetricsPlatform {
  /// Registers this class as the default instance of [DisplayMetricsPlatform].
  static void registerWith(Registrar registrar) {
    DisplayMetricsPlatform.instance = DisplayMetricsPlugin();
  }

  @override
  Future<Size?> getResolution() async {
    final devicePixelRatio = web.window.devicePixelRatio;
    final screen = web.window.screen;
    final width = screen.width.toDouble();
    final height = screen.height.toDouble();
    return Size(
      width * devicePixelRatio,
      height * devicePixelRatio,
    );
  }

  @override
  Future<Size?> getSize() async {
    final resolution = await getResolution();
    if (resolution == null) return null;
    final div = web.document.createElement('div') as web.HTMLDivElement;
    div.style.width = '1in';
    web.document.body!.append(div);
    final dpi = div.offsetWidth;
    div.remove();
    return Size(
      resolution.width / dpi,
      resolution.height / dpi,
    );
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
