// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:ui';
import 'dart:html' as html;

import 'package:display_metrics/display_metrics.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class DisplayMetricsWeb extends DisplayMetricsPlatform {
  static void registerWith(Registrar registrar) {
    DisplayMetricsPlatform.instance = DisplayMetricsWeb();
  }

  @override
  Future<Size?> getResolution() async {
    final devicePixelRatio = html.window.devicePixelRatio;
    final screen = html.window.screen;
    final width = screen?.width?.toDouble();
    final height = screen?.height?.toDouble();
    if (width == null || height == null) return null;
    return Size(width * devicePixelRatio, height * devicePixelRatio);
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
    final width = resolution.width / dpi;
    final height = resolution.height / dpi;
    return Size(width, height);
  }
}
