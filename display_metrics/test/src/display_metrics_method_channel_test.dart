import 'package:display_metrics_platform_interface/display_metrics_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelDisplayMetrics();
  const mockChannel = MockChannel();
  mockChannel.setup();
  mockChannel.teardown();

  test('getResolution', () async {
    expect(await platform.getResolution(), const Size(480, 640));
  });

  test(
    'getSize',
    () async {
      expect(await platform.getSize(), const Size(3, 4));
    },
  );
}
