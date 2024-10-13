import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';

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
