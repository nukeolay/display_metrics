import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';

/// Widget that provides access to [DisplayMetricsData]
class DisplayMetrics extends InheritedWidget {
  /// Widget that provides access to [DisplayMetricsData]
  const DisplayMetrics({
    required this.data,
    required super.child,
    super.key,
  });

  /// data that contains display metrics
  final DisplayMetricsData? data;

  /// method to get DisplayMetricsData
  static DisplayMetricsData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DisplayMetrics>()?.data;
  }

  /// method to get DisplayMetricsData
  static DisplayMetricsData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<DisplayMetrics>();
    assert(widget != null, 'No DisplayMetrics found in context');
    final data = maybeOf(context);
    assert(data != null, 'DisplayMetricsData has not been loaded yet');
    return data!;
  }

  @override
  bool updateShouldNotify(covariant DisplayMetrics oldWidget) {
    return data != oldWidget.data;
  }
}
