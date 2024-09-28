import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics/src/display_metrics_method_channel.dart';

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
