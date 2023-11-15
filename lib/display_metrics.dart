import 'dart:async';

import 'package:display_metrics/data.dart';
import 'package:flutter/widgets.dart';

import 'display_metrics_platform_interface.dart';

class DisplayMetrics extends InheritedWidget {
  const DisplayMetrics({
    required this.data,
    required super.child,
    super.key,
  });

  final DisplayMetricsData? data;

  static DisplayMetricsData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DisplayMetrics>()?.data;
  }

  static DisplayMetricsData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No DisplayMetrics found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(covariant DisplayMetrics oldWidget) {
    return data != oldWidget.data;
  }
}

class DisplayMetricsWidget extends StatefulWidget {
  const DisplayMetricsWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<DisplayMetricsWidget> createState() => _DisplayMetricsWidgetState();
}

class _DisplayMetricsWidgetState extends State<DisplayMetricsWidget> {
  DisplayMetricsData? _data;

  @override
  void didChangeDependencies() {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    if (devicePixelRatio != null) {
      _updateDisplayMetrics(devicePixelRatio);
    }
    super.didChangeDependencies();
  }

  Future<void> _updateDisplayMetrics(double devicePixelRatio) async {
    final physicalSize = await DisplayMetricsPlatform.instance.getSize();
    final resolution = await DisplayMetricsPlatform.instance.getResolution();
    if (physicalSize == null || resolution == null) return;
    setState(() {
      _data = DisplayMetricsData(
        physicalSize: physicalSize,
        resolution: resolution,
        devicePixelRatio: devicePixelRatio,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetrics(
      data: _data,
      child: widget.child,
    );
  }
}
