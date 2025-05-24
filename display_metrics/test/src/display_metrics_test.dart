import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

import 'utils/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('display_metrics');
  setUp(
    () {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          await Future.delayed(const Duration(seconds: 4));
          if (methodCall.method == 'getResolution') {
            return {'width': 480, 'height': 640};
          } else if (methodCall.method == 'getSize') {
            return {'width': 3, 'height': 4};
          }
          return null;
        },
      );
    },
  );

  tearDown(
    () {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    },
  );

  testWidgets(
    'DisplayMetrics ensureInitialized',
    (WidgetTester tester) async {
      Future<DisplayMetricsData>? ensureInitialized;

      await tester.pumpWidget(
        DisplayMetricsWidget(
          child: MaterialApp(
            home: Scaffold(
              body: DisplayMetricsTestWidget(
                onBuild: (context) async {
                  ensureInitialized = DisplayMetrics.ensureInitialized(context);
                },
              ),
            ),
          ),
        ),
        duration: Duration.zero,
      );
      await tester.pump(const Duration(seconds: 10));
      final displayMetricsData = await ensureInitialized;
      final platform = Platform.operatingSystem;
      if (kIsWeb) {
        expect(displayMetricsData != null, true);
        return;
      }
      switch (platform) {
        case 'android':
        case 'ios':
        case 'windows':
        case 'macos':
        case 'linux':
          expect(displayMetricsData != null, true);
          break;
        default:
          expect(displayMetricsData == null, true);
      }
    },
  );

  const data = DisplayMetricsData(
    displays: [
      ExtendedPhysicalDisplayData(
        physicalSize: Size(3, 4),
        resolution: Size(480, 640),
        devicePixelRatio: 1,
        isPrimary: true,
      ),
    ],
  );

  testWidgets(
    'DisplayMetrics assert',
    (WidgetTester tester) async {
      late final AssertionError assertionError;

      await tester.pumpWidget(
        DisplayMetricsTestWidget(
          onBuild: DisplayMetrics.of,
          onError: (error) => assertionError = error as AssertionError,
        ),
      );

      expect(
        assertionError.message,
        'No DisplayMetrics found in context',
      );
    },
  );

  testWidgets(
    'DisplayMetrics maybeOf',
    (WidgetTester tester) async {
      late final DisplayMetricsData? displayMetricsData;

      await tester.pumpWidget(
        DisplayMetricsTestWidget(
          onBuild: (context) =>
              displayMetricsData = DisplayMetrics.maybeOf(context),
        ),
      );

      expect(displayMetricsData, null);
    },
  );

  testWidgets(
    'DisplayMetrics of',
    (WidgetTester tester) async {
      late final DisplayMetricsData displayMetricsData;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            displayMetricsData = DisplayMetrics.of(context);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(displayMetricsData, data);
    },
  );

  testWidgets(
    'DisplayMetrics updateShouldNotify',
    (WidgetTester tester) async {
      DisplayMetricsData? displayMetricsData;
      final updatedData = data.copyWith(
        displays: [
          data.displays.first.copyWith(
            physicalSize: const Size(1, 1),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisplayMetricsUpdateTestWidget(
              initialData: data,
              updatedData: updatedData,
              child: DisplayMetricsTestWidget(
                onBuild: (context) =>
                    displayMetricsData = DisplayMetrics.of(context),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(displayMetricsData, updatedData);
    },
  );
}
