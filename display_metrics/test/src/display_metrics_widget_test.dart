import 'dart:async';
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

  group(
    'Plugin returns correct data',
    () {
      setUp(
        () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            channel,
            (MethodCall methodCall) async {
              if (methodCall.method == 'getResolution') {
                return {'width': 1206, 'height': 2622};
              } else if (methodCall.method == 'getSize') {
                return {'width': 2.6, 'height': 5.7};
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
            case 'macos':
            case 'linux':
              expect(displayMetricsData != null, true);
              break;
            default:
              expect(displayMetricsData == null, true);
          }
        },
      );

      testWidgets(
        'DisplayMetricsWidget _performUpdate',
        (WidgetTester tester) async {
          Future<DisplayMetricsData>? ensureInitialized;
          DisplayMetricsData? metrics;
          final testWidget = DisplayMetricsWidget(
            child: DisplayMetricsTestWidget(
              onBuild: (context) {
                ensureInitialized = DisplayMetrics.ensureInitialized(context);
                metrics = DisplayMetrics.maybeOf(context);
              },
            ),
          );
          const size = Size(1206, 2622);
          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(size: size),
              child: testWidget,
            ),
          );
          await tester.pumpAndSettle();
          await ensureInitialized;
          expect(metrics?.resolution.aspectRatio, size.aspectRatio);
          final flippedSize = size.flipped;
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(size: flippedSize),
              child: testWidget,
            ),
          );
          await tester.pumpAndSettle();
          await ensureInitialized;
          expect(metrics?.resolution.aspectRatio, flippedSize.aspectRatio);
        },
      );

      testWidgets(
        'throws StateError when MediaQuery is not in context',
        (WidgetTester tester) async {
          Future<DisplayMetricsData>? ensureInitialized;
          Object? handledError;
          await runZonedGuarded(
            () async {
              final originalErrorHandler = FlutterError.onError;
              FlutterError.onError = null;
              try {
                await tester.pumpWidget(
                  DisplayMetricsWidget(
                    child: View(
                      view: WidgetsBinding
                          .instance.platformDispatcher.views.first,
                      child: Builder(builder: (context) {
                        ensureInitialized =
                            DisplayMetrics.ensureInitialized(context);
                        return const Placeholder();
                      }),
                    ),
                  ),
                  wrapWithView: false,
                );
                await ensureInitialized;
              } catch (error) {
                handledError = error;
              }
              FlutterError.onError = originalErrorHandler;
            },
            (error, stack) {},
          );
          expect(handledError, isA<StateError>());
          expect(
            (handledError as StateError).message,
            'Could not get MediaQuery from BuildContext',
          );
        },
      );
    },
  );

  group(
    'Plugin returns null',
    () {
      setUp(
        () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            channel,
            (MethodCall methodCall) => null,
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
        'throws StateError when DisplayMetricsPlatform returns null',
        (WidgetTester tester) async {
          Future<DisplayMetricsData>? ensureInitialized;
          Object? handledError;
          await runZonedGuarded(
            () async {
              final originalErrorHandler = FlutterError.onError;
              FlutterError.onError = null;
              try {
                await tester.pumpWidget(
                  DisplayMetricsWidget(
                    child: Builder(
                      builder: (context) {
                        ensureInitialized =
                            DisplayMetrics.ensureInitialized(context);
                        return const Placeholder();
                      },
                    ),
                  ),
                );
                await ensureInitialized;
              } catch (error) {
                handledError = error;
              }
              FlutterError.onError = originalErrorHandler;
            },
            (error, stack) {},
          );
          expect(handledError, isA<StateError>());
          expect(
            (handledError as StateError).message,
            'Failed to load display metrics data',
          );
        },
      );
    },
  );

  group(
    'Plugin throws exception',
    () {
      setUp(
        () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            channel,
            (MethodCall methodCall) => throw PlatformException(
              code: 'TEST ERROR',
            ),
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
        'unexpected error during initial display metrics load',
        (WidgetTester tester) async {
          Future<DisplayMetricsData>? ensureInitialized;
          Object? handledError;
          await runZonedGuarded(
            () async {
              final originalErrorHandler = FlutterError.onError;
              FlutterError.onError = null;
              try {
                await tester.pumpWidget(
                  DisplayMetricsWidget(
                    child: Builder(
                      builder: (context) {
                        ensureInitialized =
                            DisplayMetrics.ensureInitialized(context);
                        return const Placeholder();
                      },
                    ),
                  ),
                );
                await ensureInitialized;
              } catch (error) {
                handledError = error;
              }
              FlutterError.onError = originalErrorHandler;
            },
            (error, stack) {},
          );
          expect(handledError, isA<PlatformException>());
          final code = (handledError as PlatformException).code;
          expect(code, 'TEST ERROR');
        },
      );
    },
  );
}
