import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// Widget that provides access to [DisplayMetrics]
class DisplayMetricsWidget extends StatefulWidget {
  /// Add [DisplayMetricsWidget] to Widget tree above MaterialApp to use
  /// DisplayMetrics.of(context) and BuildContext extension methods
  const DisplayMetricsWidget({
    required this.child,
    this.updateSizeOnRotate = false,
    super.key,
  });

  /// Widget that will be displayed
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
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    if (devicePixelRatio == null) return;
    _updateData(
      devicePixelRatio,
      widget.updateSizeOnRotate ? MediaQuery.orientationOf(context) : null,
    ).then((data) => data != null ? setState(() => _data = data) : null);
  }


  Future<DisplayMetricsData?> _updateData(
    double devicePixelRatio,
    Orientation? orientation,
  ) async {
    final physicalSize = await DisplayMetricsPlatform.instance.getSize();
    final resolution = await DisplayMetricsPlatform.instance.getResolution();
    if (physicalSize == null || resolution == null) return null;
    return DisplayMetricsData(
      physicalSize: physicalSize.byOrientation(orientation),
      resolution: resolution.byOrientation(orientation),
      devicePixelRatio: devicePixelRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetrics(
      data: _data,
      child: widget.child,
    );
  }
}
