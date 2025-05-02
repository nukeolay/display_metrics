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
  late final Completer<DisplayMetricsData> _loadCompleter;
  late final Future<DisplayMetricsData> _loadFuture;
  bool _initialLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    _loadCompleter = Completer();
    _loadFuture = _loadCompleter.future;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    final orientation =
        widget.updateSizeOnRotate ? MediaQuery.orientationOf(context) : null;

    if (devicePixelRatio == null) {
      _handlePixelRatioError();
      return;
    }

    if (!_initialLoadAttempted) {
      _initialLoadAttempted = true;
      unawaited(_performInitialLoad(devicePixelRatio, orientation));
      return;
    }

    if (widget.updateSizeOnRotate) {
      debugPrint('Orientation changed: $orientation');
      unawaited(_performUpdate(devicePixelRatio, orientation));
    }
  }

  void _handlePixelRatioError() {
    if (_initialLoadAttempted) return;
    _maybeCompleteWithError(
      StateError('Could not get devicePixelRatio from MediaQuery'),
      StackTrace.current,
    );
  }

  Future<void> _performInitialLoad(
    double devicePixelRatio,
    Orientation? orientation,
  ) async {
    try {
      final data = await _updateData(devicePixelRatio, orientation);

      if (data == null) {
        _maybeCompleteWithError(
          StateError('Failed to load display metrics data'),
          StackTrace.current,
        );
        return;
      }

      if (!mounted) return;

      setState(() => _data = data);

      if (_loadCompleter.isCompleted) return;

      _loadCompleter.complete(data);
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected error '
        'during initial display metrics load: $error\n$stackTrace',
      );
      _maybeCompleteWithError(error, stackTrace);
    }
  }

  Future<void> _performUpdate(
    double devicePixelRatio,
    Orientation? orientation,
  ) async {
    try {
      final data = await _updateData(devicePixelRatio, orientation);
      if (data == null) return;
      if (!mounted) return;
      setState(() => _data = data);
    } catch (error, stackTrace) {
      debugPrint('Error during display metrics update: $error\n$stackTrace');
    }
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

  void _maybeCompleteWithError(Object error, StackTrace stackTrace) {
    if (_loadCompleter.isCompleted) return;
    _loadCompleter.completeError(error, stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetrics(
      loadFuture: _loadFuture,
      data: _data,
      child: widget.child,
    );
  }
}
