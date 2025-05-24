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
    super.key,
  });

  /// Widget that will be displayed
  final Widget child;

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
    // subscribe for size update to track if size of display has been changed
    // so we will update DisplayMetricsData
    // ! this line causes multiple rebuilds, so its now disabled
    // MediaQuery.maybeSizeOf(context);
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    final orientation = MediaQuery.maybeOrientationOf(context);

    if (devicePixelRatio == null || orientation == null) {
      _handlMediaQueryError();
      return;
    }

    if (!_initialLoadAttempted) {
      _initialLoadAttempted = true;
      unawaited(_performInitialLoad(devicePixelRatio, orientation));
      return;
    }

    unawaited(_performUpdate(devicePixelRatio, orientation));
  }

  void _handlMediaQueryError() {
    if (_initialLoadAttempted) return;
    _maybeCompleteWithError(
      StateError('Could not get MediaQuery from BuildContext'),
      StackTrace.current,
    );
  }

  Future<void> _performInitialLoad(
    double devicePixelRatio,
    Orientation orientation,
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
    Orientation orientation,
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
    Orientation orientation,
  ) async {
    final displays = await DisplayMetricsPlatform.instance.getDisplays();
    final extendedDisplays = displays.map((display) {
      return ExtendedPhysicalDisplayData.fromDisplayData(
        display,
        devicePixelRatio: devicePixelRatio,
      );
    });
    final updatedDisplays = extendedDisplays.map((display) {
      return display.copyWith(
        physicalSize: display.physicalSize.byOrientation(orientation),
        resolution: display.resolution.byOrientation(orientation),
        devicePixelRatio: devicePixelRatio,
      );
    }).toList();
    if (displays.isEmpty) return null;
    return DisplayMetricsData(displays: updatedDisplays);
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
