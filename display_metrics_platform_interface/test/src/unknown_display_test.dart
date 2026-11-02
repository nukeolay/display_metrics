import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatform extends DisplayMetricsPlatform {
  _FakePlatform(this.displays);

  final List<PhysicalDisplayData> displays;

  @override
  Future<List<PhysicalDisplayData>> getDisplays() async => displays;

  @override
  Future<Size?> getResolution() => throw UnimplementedError();

  @override
  Future<Size?> getSize() => throw UnimplementedError();
}

void main() {
  test('toDisplayData keeps resolution aspect and diagonal', () {
    const info = UnknownDisplayInfo(
      resolution: Size(1398, 2034),
      isPrimary: true,
    );
    final data = info.toDisplayData(5.4);
    expect(data.diagonal, closeTo(5.4, 1e-9));
    expect(data.physicalSize.aspectRatio, closeTo(1398 / 2034, 1e-9));
    expect(data.resolution, const Size(1398, 2034));
    expect(data.isPrimary, true);
  });

  test('toString formats', () {
    expect(
      const UnknownDisplayInfo(
        resolution: Size(1398, 2034),
        isPrimary: true,
      ).toString(),
      'unknown display (resolution: 1398x2034)',
    );
  });

  test('equality', () {
    const a = UnknownDisplayInfo(resolution: Size(1398, 2034), isPrimary: true);
    const b = UnknownDisplayInfo(resolution: Size(1398, 2034), isPrimary: true);
    const c =
        UnknownDisplayInfo(resolution: Size(1398, 2034), isPrimary: false);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, false);
  });

  test('default getDisplaysReport delegates to getDisplays', () async {
    const displays = [
      PhysicalDisplayData(
        physicalSize: Size(2.6, 5.7),
        resolution: Size(1206, 2622),
        isPrimary: true,
      ),
      PhysicalDisplayData(
        physicalSize: Size(10, 6),
        resolution: Size(1920, 1080),
        isPrimary: false,
      ),
    ];
    final report = await _FakePlatform(displays).getDisplaysReport();
    expect(report.known, displays);
    expect(report.unknown, isEmpty);
  });
}
