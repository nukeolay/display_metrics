import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/fake_platform.dart';

const _duoOuter = IosUnknownDisplayInfo(
  resolution: Size(1398, 2034),
  isPrimary: true,
  modelIdentifier: 'iPhone19,4',
);

const _duoError = 'Failed to load display metrics data: '
    'unknown display (iOS model identifier: iPhone19,4, '
    'resolution: 1398x2034)';

void main() {
  late FakeDisplayMetricsPlatform platform;

  setUp(() {
    platform = FakeDisplayMetricsPlatform(
      const DisplaysReport(known: [], unknown: [_duoOuter]),
    );
    DisplayMetricsPlatform.instance = platform;
  });

  tearDown(() {
    DisplayMetricsPlatform.instance = MethodChannelDisplayMetrics();
  });

  DisplayMetricsData? metrics;
  Future<DisplayMetricsData>? ensureInitialized;

  Widget app({UnknownDisplayCallback? onUnknownDisplay}) {
    return DisplayMetricsWidget(
      onUnknownDisplay: onUnknownDisplay,
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            metrics = DisplayMetrics.maybeOf(context);
            ensureInitialized = DisplayMetrics.ensureInitialized(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  setUp(() {
    metrics = null;
    ensureInitialized = null;
  });

  group('initial load', () {
    testWidgets('callback resolves unknown primary', (tester) async {
      UnknownDisplayInfo? received;
      await tester.pumpWidget(app(onUnknownDisplay: (info) {
        received = info;
        return 5.4;
      }));
      await tester.pumpAndSettle();
      expect(metrics, isNotNull);
      expect(metrics!.diagonal, closeTo(5.4, 1e-9));
      expect(received, isA<IosUnknownDisplayInfo>());
      expect(
          (received! as IosUnknownDisplayInfo).modelIdentifier, 'iPhone19,4');
    });

    testWidgets('no callback: no uncaught error', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(metrics, isNull);
    });

    testWidgets('ensureInitialized error names the device', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await expectLater(
        ensureInitialized,
        throwsA(
            isA<StateError>().having((e) => e.message, 'message', _duoError)),
      );
    });

    testWidgets('callback returning null', (tester) async {
      await tester.pumpWidget(app(onUnknownDisplay: (_) => null));
      await tester.pumpAndSettle();
      expect(metrics, isNull);
      await expectLater(
        ensureInitialized,
        throwsA(
            isA<StateError>().having((e) => e.message, 'message', _duoError)),
      );
    });

    for (final value in [0.0, -1.0, double.nan, double.infinity]) {
      testWidgets('invalid diagonal $value', (tester) async {
        await tester.pumpWidget(app(onUnknownDisplay: (_) => value));
        await tester.pumpAndSettle();
        expect(metrics, isNull);
      });
    }

    testWidgets('callback throws', (tester) async {
      await tester.pumpWidget(
        app(onUnknownDisplay: (_) => throw Exception('x')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<Exception>());
      expect(metrics, isNull);
    });

    testWidgets('callback error reported once per display', (tester) async {
      Widget throwing(Size size) => MediaQuery(
            data: MediaQueryData(size: size),
            child: app(onUnknownDisplay: (_) => throw Exception('x')),
          );
      await tester.pumpWidget(throwing(const Size(1398, 2034)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<Exception>());

      await tester.pumpWidget(throwing(const Size(2034, 1398)));
      await tester.pumpAndSettle();
      expect(platform.reportCalls, greaterThanOrEqualTo(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('load failure without unknown displays is logged',
        (tester) async {
      platform.report = const DisplaysReport(known: []);
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
      } finally {
        debugPrint = originalDebugPrint;
      }
      expect(metrics, isNull);
      expect(
        logs.where(
            (log) => log.contains('Failed to load display metrics data')),
        hasLength(1),
      );
    });

    testWidgets('known and unknown merged', (tester) async {
      platform.report = const DisplaysReport(
        known: [
          PhysicalDisplayData(
            physicalSize: Size(16, 9),
            resolution: Size(1920, 1080),
            isPrimary: false,
          ),
        ],
        unknown: [
          UnknownDisplayInfo(resolution: Size(1080, 2400), isPrimary: true),
        ],
      );
      await tester.pumpWidget(app(onUnknownDisplay: (_) => 6.1));
      await tester.pumpAndSettle();
      expect(metrics!.displays.length, 2);
      expect(metrics!.primaryDisplay.diagonal, closeTo(6.1, 1e-9));
    });

    testWidgets('unresolved display logged once', (tester) async {
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        for (final size in const [Size(1398, 2034), Size(2034, 1398)]) {
          await tester.pumpWidget(
            MediaQuery(data: MediaQueryData(size: size), child: app()),
          );
          await tester.pumpAndSettle();
        }
      } finally {
        debugPrint = originalDebugPrint;
      }
      await tester.pumpAndSettle();
      expect(platform.reportCalls, greaterThanOrEqualTo(2));
      expect(logs.where((log) => log.contains('iPhone19,4')).length, 1);
    });
  });

  group('refetch', () {
    const outer = Size(1398, 2034);
    const inner = Size(1878, 2670);
    const debounce = Duration(milliseconds: 250);

    Future<void> setScreen(WidgetTester tester, Size size) async {
      platform.report = DisplaysReport(
        known: const [],
        unknown: [
          IosUnknownDisplayInfo(
            resolution: size,
            isPrimary: true,
            modelIdentifier: 'iPhone19,4',
          ),
        ],
      );
      tester.view.physicalSize = size;
    }

    double? duo(UnknownDisplayInfo info) =>
        info.resolution.shortestSide > 1398 ? 7.6 : 5.4;

    testWidgets('refetches after window size change', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(onUnknownDisplay: duo));
      await tester.pumpAndSettle();
      expect(metrics!.diagonal, closeTo(5.4, 1e-9));

      await setScreen(tester, inner);
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(metrics!.diagonal, closeTo(7.6, 1e-9));
    });

    testWidgets('debounces', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(onUnknownDisplay: duo));
      await tester.pumpAndSettle();
      final calls = platform.reportCalls;

      for (final size in const [inner, Size(1800, 2600), inner]) {
        await setScreen(tester, size);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(platform.reportCalls, calls + 1);
    });

    testWidgets('no refetch when size unchanged', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(onUnknownDisplay: duo));
      await tester.pumpAndSettle();
      final calls = platform.reportCalls;

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(platform.reportCalls, calls);
    });

    testWidgets('keeps previous data when callback returns null on update',
        (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(
        onUnknownDisplay: (info) =>
            info.resolution.shortestSide > 1398 ? null : 5.4,
      ));
      await tester.pumpAndSettle();

      await setScreen(tester, inner);
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(platform.reportCalls, greaterThanOrEqualTo(2));
      expect(metrics!.diagonal, closeTo(5.4, 1e-9));
    });

    testWidgets('recovers after failed initial load', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(
        onUnknownDisplay: (info) =>
            info.resolution.shortestSide > 1398 ? 7.6 : null,
      ));
      await tester.pumpAndSettle();
      expect(metrics, isNull);

      await setScreen(tester, inner);
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(metrics!.diagonal, closeTo(7.6, 1e-9));
      expect((await ensureInitialized)!.diagonal, closeTo(7.6, 1e-9));
    });

    testWidgets('dispose during debounce', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(onUnknownDisplay: duo));
      await tester.pumpAndSettle();
      final calls = platform.reportCalls;

      await setScreen(tester, inner);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(debounce);
      expect(tester.takeException(), isNull);
      expect(platform.reportCalls, calls);
    });

    testWidgets('single fetch on rotation', (tester) async {
      addTearDown(tester.view.reset);
      await setScreen(tester, outer);
      await tester.pumpWidget(app(onUnknownDisplay: duo));
      await tester.pumpAndSettle();
      final calls = platform.reportCalls;

      await setScreen(tester, outer.flipped);
      await tester.pump();
      await tester.pump(debounce);
      await tester.pumpAndSettle();
      expect(platform.reportCalls, calls + 1);
    });

    DisplaysReport reportFor(Size size) => DisplaysReport(
          known: const [],
          unknown: [
            IosUnknownDisplayInfo(
              resolution: size,
              isPrimary: true,
              modelIdentifier: 'iPhone19,4',
            ),
          ],
        );

    testWidgets('latest request wins over stale success', (tester) async {
      addTearDown(tester.view.reset);
      platform.gated = true;
      await setScreen(tester, outer);
      await tester.pumpWidget(app(
        onUnknownDisplay: (info) =>
            info.resolution.shortestSide > 1398 ? null : 5.4,
      ));
      final awaitedBeforeLoad = ensureInitialized!;
      await setScreen(tester, inner);
      await tester.pump(debounce);
      expect(platform.pending.length, 2);

      platform.pending[1].complete(reportFor(inner));
      await tester.pump();
      platform.pending[0].complete(reportFor(outer));
      await tester.pumpAndSettle();

      expect(metrics, isNull);
      await expectLater(awaitedBeforeLoad, throwsA(isA<StateError>()));
    });

    testWidgets('stale failure does not override newer success',
        (tester) async {
      addTearDown(tester.view.reset);
      platform.gated = true;
      await setScreen(tester, outer);
      await tester.pumpWidget(app(
        onUnknownDisplay: (info) =>
            info.resolution.shortestSide > 1398 ? 7.6 : null,
      ));
      final awaitedBeforeLoad = ensureInitialized!;
      await setScreen(tester, inner);
      await tester.pump(debounce);
      expect(platform.pending.length, 2);

      platform.pending[1].complete(reportFor(inner));
      platform.pending[0].complete(reportFor(outer));
      await tester.pumpAndSettle();

      expect(metrics?.diagonal, closeTo(7.6, 1e-9));
      expect((await awaitedBeforeLoad).diagonal, closeTo(7.6, 1e-9));
    });
  });
}
