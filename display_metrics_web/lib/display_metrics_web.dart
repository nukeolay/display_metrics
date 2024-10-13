import 'dart:ui';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';


class DisplayMetricsPlugin extends DisplayMetricsPlatform {
  static void registerWith(Registrar registrar) {
    DisplayMetricsPlatform.instance = DisplayMetricsPlugin();
  }

  @override
  Future<Size?> getResolution() async {
    final devicePixelRatio = html.window.devicePixelRatio;
    final screen = html.window.screen;
    final width = screen?.width?.toDouble();
    final height = screen?.height?.toDouble();
    if (width == null || height == null) return null;
    return Size(
      width * devicePixelRatio,
      height * devicePixelRatio,
    );
  }

  @override
  Future<Size?> getSize() async {
    final resolution = await getResolution();
    if (resolution == null) return null;
    final div = html.DivElement();
    div.style.width = '1in';
    html.document.body!.append(div);
    final devicePixelRatio = html.window.devicePixelRatio;
    final dpi = div.offsetWidth * devicePixelRatio;
    div.remove();
    return Size(
      resolution.width / dpi,
      resolution.height / dpi,
    );
  }
}
