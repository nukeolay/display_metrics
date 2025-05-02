import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';

/// Widget that provides access to [DisplayMetricsData]
class DisplayMetrics extends InheritedWidget {
  /// Widget that provides access to [DisplayMetricsData]
  const DisplayMetrics({
    required this.data,
    required super.child,
    Future<DisplayMetricsData>? loadFuture,
    super.key,
  }) : _loadFuture = loadFuture;

  /// data that contains display metrics
  final DisplayMetricsData? data;

  final Future<DisplayMetricsData>? _loadFuture;

  /// method to ensure [DisplayMetricsData] has been loaded
  static Future<DisplayMetricsData>? ensureInitialized(BuildContext context) {
    final metrics =
        context.dependOnInheritedWidgetOfExactType<DisplayMetrics>();
    final data = metrics?.data;
    if (data != null) return Future.value(data);
    return metrics?._loadFuture;
  }

  /// method to get [DisplayMetricsData]
  static DisplayMetricsData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DisplayMetrics>()?.data;
  }

  /// method to get [DisplayMetricsData]
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
