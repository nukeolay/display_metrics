import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics/display_metrics_platform_interface.dart';
import 'package:display_metrics/display_metrics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDisplayMetricsPlatform
    with MockPlatformInterfaceMixin
    implements DisplayMetricsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DisplayMetricsPlatform initialPlatform = DisplayMetricsPlatform.instance;

  test('$MethodChannelDisplayMetrics is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDisplayMetrics>());
  });

  test('getPlatformVersion', () async {
    DisplayMetrics displayMetricsPlugin = DisplayMetrics();
    MockDisplayMetricsPlatform fakePlatform = MockDisplayMetricsPlatform();
    DisplayMetricsPlatform.instance = fakePlatform;

    expect(await displayMetricsPlugin.getPlatformVersion(), '42');
  });
}
