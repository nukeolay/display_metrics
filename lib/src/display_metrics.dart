import 'dart:async';
import 'dart:io';

import 'package:display_metrics/src/data.dart';
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
    this.updateSizeOnRotate = false,
    super.key,
  });

  final Widget child;

  /// Set this to true if you need to update size when orientation of your device changes
  final bool updateSizeOnRotate;

  @override
  State<DisplayMetricsWidget> createState() => _DisplayMetricsWidgetState();
}

class _DisplayMetricsWidgetState extends State<DisplayMetricsWidget> {
  DisplayMetricsData? _data;

  @override
  void didChangeDependencies() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    if (devicePixelRatio != null) {
      _updateDisplayMetrics(
        devicePixelRatio,
        widget.updateSizeOnRotate ? MediaQuery.orientationOf(context) : null,
      );
    }
    super.didChangeDependencies();
  }

  Future<void> _updateDisplayMetrics(
    double devicePixelRatio,
    Orientation? orientation,
  ) async {
    final physicalSize = await DisplayMetricsPlatform.instance.getSize();
    final resolution = await DisplayMetricsPlatform.instance.getResolution();
    if (physicalSize == null || resolution == null) return;
    setState(() {
      _data = DisplayMetricsData(
        physicalSize: _sizeByOrientation(physicalSize, orientation),
        resolution: _sizeByOrientation(resolution, orientation),
        devicePixelRatio: devicePixelRatio,
      );
    });
  }

  Size _sizeByOrientation(
    Size size,
    Orientation? orientation,
  ) {
    if (orientation == null) return size;
    switch (orientation) {
      case Orientation.portrait:
        return Size(size.shortestSide, size.longestSide);
      case Orientation.landscape:
        return Size(size.longestSide, size.shortestSide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetrics(
      data: _data,
      child: widget.child,
    );
  }
}
