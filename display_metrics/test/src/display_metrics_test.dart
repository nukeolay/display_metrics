import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

import 'utils/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const data = DisplayMetricsData(
    physicalSize: Size(3, 4),
    resolution: Size(480, 640),
    devicePixelRatio: 1,
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
        physicalSize: const Size(1, 1),
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
