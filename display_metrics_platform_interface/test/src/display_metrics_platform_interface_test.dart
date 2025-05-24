import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'get instance',
    () {
      final instance = DisplayMetricsPlatform.instance;
      expect(
        instance.runtimeType,
        MethodChannelDisplayMetrics().runtimeType,
      );
    },
  );

  test(
    'set instance',
    () {
      final channel = MethodChannelDisplayMetrics();
      DisplayMetricsPlatform.instance = channel;
      expect(
        DisplayMetricsPlatform.instance,
        channel,
      );
    },
  );
}
