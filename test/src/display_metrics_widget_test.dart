import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

import 'display_metrics_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'DisplayMetricsWidget',
    (WidgetTester tester) async {
      DisplayMetricsData? displayMetricsData;

      await tester.pumpWidget(
        DisplayMetricsWidget(
          child: MaterialApp(
            home: Scaffold(
              body: DisplayMetricsTestWidget(
                onBuild: (context) {
                  displayMetricsData = DisplayMetrics.of(context);
                },
              ),
            ),
          ),
        ),
      );
      // await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      final platform = Platform.operatingSystem;
      switch (platform) {
        case 'android':
        case 'ios':
          expect(displayMetricsData != null, true);
          break;
        default:
          expect(displayMetricsData == null, true);
      }
    },
  );
}
