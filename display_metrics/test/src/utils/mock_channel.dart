import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChannel {
  const MockChannel([this.channel = const MethodChannel('display_metrics')]);
  final MethodChannel channel;

  void setup() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUp(
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('display_metrics'),
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
  }

  void teardown() {
    tearDown(
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      },
    );
  }
}
