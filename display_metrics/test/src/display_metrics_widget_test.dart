import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

import 'utils/mock_channel.dart';
import 'utils/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const mockChannel = MockChannel();
  mockChannel.setup();
  mockChannel.teardown();

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
      await tester.pumpAndSettle();
      final platform = Platform.operatingSystem;
      if (kIsWeb) {
        expect(displayMetricsData != null, true);
        return;
      }
      switch (platform) {
        case 'android':
        case 'ios':
        case 'windows':
          expect(displayMetricsData != null, true);
          break;
        default:
          expect(displayMetricsData == null, true);
      }
    },
  );
}
