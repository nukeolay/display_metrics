import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';

class DisplayMetricsWidget extends StatefulWidget {
  /// Add [DisplayMetricsWidget] to Widget tree above MaterialApp to use
  /// DisplayMetrics.of(context) and BuildContext extension methods
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
    super.didChangeDependencies();
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    if (devicePixelRatio != null) {
      _updateDisplayMetrics(
        devicePixelRatio,
        widget.updateSizeOnRotate ? MediaQuery.orientationOf(context) : null,
      );
    }
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
