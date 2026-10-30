import 'dart:async';
import 'dart:ui';

import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

class FakeDisplayMetricsPlatform extends DisplayMetricsPlatform {
  FakeDisplayMetricsPlatform(this.report);

  DisplaysReport report;
  int reportCalls = 0;

  /// When true, every request waits until its completer in [pending] completes
  bool gated = false;
  final pending = <Completer<DisplaysReport>>[];

  @override
  Future<DisplaysReport> getDisplaysReport() async {
    reportCalls++;
    if (!gated) return report;
    final completer = Completer<DisplaysReport>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<List<PhysicalDisplayData>> getDisplays() => throw UnimplementedError();

  @override
  Future<Size?> getResolution() => throw UnimplementedError();

  @override
  Future<Size?> getSize() => throw UnimplementedError();
}
