import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

import 'display_metrics_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const data = DisplayMetricsData(
    physicalSize: Size(1, 1),
    resolution: Size(1, 1),
    devicePixelRatio: 1,
  );

  testWidgets(
    'inchesToPixels',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            pixels = context.inchesToPixels(1);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 1);
    },
  );

  testWidgets(
    'mmToPixels',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            pixels = context.mmToPixels(25.4);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 1);
    },
  );

  testWidgets(
    'cmToPixels',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            // ignore: deprecated_member_use_from_same_package
            pixels = context.cmToPixels(2.54);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 1);
    },
  );

  testWidgets(
    'pixelsToInches',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            pixels = context.pixelsToInches(1);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 1);
    },
  );

  testWidgets(
    'pixelsToMm',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            pixels = context.pixelsToMm(1);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 25.4);
    },
  );

  testWidgets(
    'pixelsToCm',
    (WidgetTester tester) async {
      late final double pixels;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            // ignore: deprecated_member_use_from_same_package
            pixels = context.pixelsToCm(1);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(pixels, 2.54);
    },
  );
}
