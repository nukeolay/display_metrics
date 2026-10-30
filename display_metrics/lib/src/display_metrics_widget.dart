import 'dart:async';
import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// Callback that returns diagonal in inches for display whose physical size
/// could not be determined by the platform, or null if it is unknown
typedef UnknownDisplayCallback = double? Function(UnknownDisplayInfo info);

/// Widget that provides access to [DisplayMetrics]
class DisplayMetricsWidget extends StatefulWidget {
  /// Add [DisplayMetricsWidget] to Widget tree above MaterialApp to use
  /// DisplayMetrics.of(context) and BuildContext extension methods
  const DisplayMetricsWidget({
    required this.child,
    this.onUnknownDisplay,
    super.key,
  });

  /// Widget that will be displayed
  final Widget child;

  /// Called for every display whose physical size could not be determined
  /// by the platform (for example a device released after this package
  /// version). Return the display diagonal in inches, or null if unknown.
  /// Physical size and PPI are calculated from the diagonal and resolution.
  ///
  /// * [UnknownDisplayInfo] fields depend on the platform: on iOS it is
  ///   [IosUnknownDisplayInfo] with the device model identifier.
  ///   Currently only iOS reports unknown displays.
  /// * Called on every display metrics update, so it should be cheap and
  ///   free of side effects.
  /// * If null is returned during initial load, no data is available and
  ///   [DisplayMetrics.ensureInitialized] completes with an error.
  /// * If null is returned after the display has changed (for example
  ///   a foldable device was unfolded), the previous display's data is kept
  ///   and an error is logged.
  /// * Exceptions thrown by the callback are reported with
  ///   [FlutterError.reportError] once per display and the display is treated
  ///   as unknown.
  final UnknownDisplayCallback? onUnknownDisplay;

  @override
  State<DisplayMetricsWidget> createState() => _DisplayMetricsWidgetState();
}

class _DisplayMetricsWidgetState extends State<DisplayMetricsWidget>
    with WidgetsBindingObserver {
  static const _refetchDelay = Duration(milliseconds: 200);

  DisplayMetricsData? _data;
  late final Completer<DisplayMetricsData> _loadCompleter;
  late final Future<DisplayMetricsData> _loadFuture;
  bool _initialLoadAttempted = false;
  final Set<UnknownDisplayInfo> _loggedUnknownDisplays = {};
  final Set<UnknownDisplayInfo> _reportedCallbackErrors = {};
  double? _devicePixelRatio;
  Orientation? _orientation;
  Size? _fetchedPhysicalSize;
  FlutterView? _view;
  Timer? _refetchTimer;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadCompleter = Completer();
    _loadFuture = _loadCompleter.future;
    // prevents unhandled error if nobody awaits ensureInitialized
    _loadFuture.ignore();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refetchTimer?.cancel();
    super.dispose();
  }

  Size? get _physicalSize => _view?.physicalSize;

  // tracks physical display change (for example foldable device folding)
  // that does not change devicePixelRatio or orientation
  @override
  void didChangeMetrics() {
    final physicalSize = _physicalSize;
    if (physicalSize == null || physicalSize == _fetchedPhysicalSize) return;
    _refetchTimer?.cancel();
    _refetchTimer = Timer(_refetchDelay, () {
      final devicePixelRatio = _devicePixelRatio;
      final orientation = _orientation;
      if (!mounted || devicePixelRatio == null || orientation == null) return;
      // display could have been already reloaded by didChangeDependencies
      if (_physicalSize == _fetchedPhysicalSize) return;
      unawaited(_performLoad(devicePixelRatio, orientation));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // the view this widget is shown in, it may differ from implicit view
    // in multi-view apps
    _view = View.maybeOf(context);
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
    _devicePixelRatio = devicePixelRatio;
    _orientation = orientation;

    _initialLoadAttempted = true;
    unawaited(_performLoad(devicePixelRatio, orientation));
  }

  void _handlMediaQueryError() {
    if (_initialLoadAttempted) return;
    _maybeCompleteWithError(
      StateError('Could not get MediaQuery from BuildContext'),
      StackTrace.current,
    );
  }

  Future<void> _performLoad(
    double devicePixelRatio,
    Orientation orientation,
  ) async {
    // the latest request wins, results of previous requests are dropped
    final requestId = ++_requestId;
    try {
      final (:data, :unresolved) =
          await _updateData(devicePixelRatio, orientation);
      if (!mounted || requestId != _requestId) return;
      if (data != null) {
        _setData(data);
        _maybeComplete(data);
        return;
      }
      // previous data is kept if there is any
      if (!_isLoadPending) return;
      const message = 'Failed to load display metrics data';
      final error = StateError(
        unresolved.isEmpty ? message : '$message: ${unresolved.join(', ')}',
      );
      // unresolved displays are already logged by _logUnresolved
      if (unresolved.isEmpty) debugPrint(error.message);
      _maybeCompleteWithError(error, StackTrace.current);
    } catch (error, stackTrace) {
      debugPrint('Error during display metrics load: $error\n$stackTrace');
      if (!mounted || requestId != _requestId) return;
      _maybeCompleteWithError(error, stackTrace);
    }
  }

  bool get _isLoadPending => !_loadCompleter.isCompleted && _data == null;

  void _setData(DisplayMetricsData data) {
    if (data == _data) return;
    setState(() => _data = data);
  }

  void _maybeComplete(DisplayMetricsData data) {
    if (_loadCompleter.isCompleted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_loadCompleter.isCompleted) return;
      _loadCompleter.complete(data);
    });
  }

  Future<({DisplayMetricsData? data, List<UnknownDisplayInfo> unresolved})>
      _updateData(
    double devicePixelRatio,
    Orientation orientation,
  ) async {
    _fetchedPhysicalSize = _physicalSize;
    final report = await DisplayMetricsPlatform.instance.getDisplaysReport();
    final displays = [...report.known];
    final unresolved = <UnknownDisplayInfo>[];
    for (final info in report.unknown) {
      final diagonal = _resolveDiagonal(info);
      if (diagonal == null) {
        unresolved.add(info);
      } else {
        displays.add(info.toDisplayData(diagonal));
      }
    }
    _logUnresolved(unresolved);
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
    if (!updatedDisplays.any((display) => display.isPrimary)) {
      return (data: null, unresolved: unresolved);
    }
    return (
      data: DisplayMetricsData(displays: updatedDisplays),
      unresolved: unresolved,
    );
  }

  double? _resolveDiagonal(UnknownDisplayInfo info) {
    final double? diagonal;
    try {
      diagonal = widget.onUnknownDisplay?.call(info);
    } catch (error, stackTrace) {
      // callback is called on every update, so error is reported only once
      // for each display to avoid flooding crash reports
      if (!_reportedCallbackErrors.add(info)) return null;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'display_metrics',
          context: ErrorDescription('while calling onUnknownDisplay for $info'),
        ),
      );
      return null;
    }
    if (diagonal == null || !diagonal.isFinite || diagonal <= 0) return null;
    return diagonal;
  }

  void _logUnresolved(List<UnknownDisplayInfo> unresolved) {
    for (final info in unresolved) {
      if (!_loggedUnknownDisplays.add(info)) continue;
      debugPrint(
        'Could not get display metrics: $info. '
        'Return its diagonal from DisplayMetricsWidget.onUnknownDisplay',
      );
    }
  }

  void _maybeCompleteWithError(Object error, StackTrace stackTrace) {
    if (!_isLoadPending) return;
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
