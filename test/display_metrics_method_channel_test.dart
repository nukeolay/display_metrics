import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDisplayMetrics platform = MethodChannelDisplayMetrics();
  const MethodChannel channel = MethodChannel('display_metrics');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getResolution', () async {
    expect(await platform.getResolution(), const Size(1179, 2556));
  });

  test('getSize', () async {
    expect(await platform.getSize(), const Size(2.56, 5.54));
  });
}
