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
