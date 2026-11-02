import 'package:display_metrics_ios/display_metrics_ios.dart'
    show DisplayMetricsIos, IosUnknownDisplayInfo;
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart'
    show UnknownDisplayInfo;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('display_metrics');

  void mockChannel(Map<String, Object?> responses) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async => responses[methodCall.method],
    );
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('known model', () async {
    mockChannel({
      'getSize': {'width': 2.6, 'height': 5.7},
      'getResolution': {'width': 1206, 'height': 2622},
    });
    final report = await DisplayMetricsIos().getDisplaysReport();
    expect(report.known.single.physicalSize, const Size(2.6, 5.7));
    expect(report.known.single.isPrimary, true);
    expect(report.unknown, isEmpty);
  });

  test('unknown model', () async {
    mockChannel({
      'getSize': {'width': 0, 'height': 0},
      'getResolution': {'width': 1398, 'height': 2034},
      'getModelIdentifier': 'iPhone19,4',
    });
    final report = await DisplayMetricsIos().getDisplaysReport();
    expect(report.known, isEmpty);
    expect(
      report.unknown.single,
      const IosUnknownDisplayInfo(
        resolution: Size(1398, 2034),
        isPrimary: true,
        modelIdentifier: 'iPhone19,4',
      ),
    );
  });

  test('unknown model without identifier', () async {
    mockChannel({
      'getSize': {'width': 0, 'height': 0},
      'getResolution': {'width': 1398, 'height': 2034},
      'getModelIdentifier': null,
    });
    final report = await DisplayMetricsIos().getDisplaysReport();
    expect(report.known, isEmpty);
    expect(report.unknown.single.runtimeType, UnknownDisplayInfo);
    expect(report.unknown.single.resolution, const Size(1398, 2034));
  });

  test('no resolution', () async {
    mockChannel({});
    final report = await DisplayMetricsIos().getDisplaysReport();
    expect(report.known, isEmpty);
    expect(report.unknown, isEmpty);
  });

  test('IosUnknownDisplayInfo toString', () {
    expect(
      const IosUnknownDisplayInfo(
        resolution: Size(1398, 2034),
        isPrimary: true,
        modelIdentifier: 'iPhone19,4',
      ).toString(),
      'unknown display (iOS model identifier: iPhone19,4, '
      'resolution: 1398x2034)',
    );
  });

  test('IosUnknownDisplayInfo equality', () {
    const a = IosUnknownDisplayInfo(
      resolution: Size(1398, 2034),
      isPrimary: true,
      modelIdentifier: 'iPhone19,4',
    );
    const b = IosUnknownDisplayInfo(
      resolution: Size(1398, 2034),
      isPrimary: true,
      modelIdentifier: 'iPhone19,4',
    );
    const c = IosUnknownDisplayInfo(
      resolution: Size(1398, 2034),
      isPrimary: true,
      modelIdentifier: 'iPhone19,5',
    );
    const plain = UnknownDisplayInfo(
      resolution: Size(1398, 2034),
      isPrimary: true,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, false);
    expect(a == plain, false);
    expect(plain == a, false);
  });
}
