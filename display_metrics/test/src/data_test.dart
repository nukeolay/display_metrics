import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DisplayMetricsData data;

  setUp(
    () {
      data = const DisplayMetricsData(
        displays: [
          ExtendedPhysicalDisplayData(
            physicalSize: Size(3, 4),
            resolution: Size(480, 640),
            isPrimary: true,
            devicePixelRatio: 1,
          ),
        ],
      );
    },
  );

  test(
    'diagonal',
    () {
      expect(data.diagonal, 5);
    },
  );

  test(
    'ppi',
    () {
      expect(data.ppi, 160);
    },
  );

  test(
    'inchesToLogicalPixelRatio',
    () {
      expect(data.inchesToLogicalPixelRatio, 160);
    },
  );

  test(
    'devicePixelRatio',
    () {
      expect(data.devicePixelRatio, 1);
    },
  );

  test(
    'physicalSize',
    () {
      expect(data.physicalSize, const Size(3, 4));
    },
  );

  test(
    'DisplayMetricsData.copyWith',
    () {
      expect(
        data.copyWith(
          displays: [
            data.displays.first.copyWith(
              physicalSize: const Size(10, 10),
              resolution: const Size(1000, 1000),
              isPrimary: false,
              devicePixelRatio: 2,
            ),
          ],
        ),
        const DisplayMetricsData(
          displays: [
            ExtendedPhysicalDisplayData(
              physicalSize: Size(10, 10),
              resolution: Size(1000, 1000),
              isPrimary: false,
              devicePixelRatio: 2,
            ),
          ],
        ),
      );
    },
  );

  test(
    'ExtendedPhysicalDisplayData.copyWith',
    () {
      expect(
        data.displays.first.copyWith(
          // physicalSize: const Size(10, 10),
          resolution: const Size(1000, 1000),
          isPrimary: false,
          devicePixelRatio: 2,
        ),
        const ExtendedPhysicalDisplayData(
          physicalSize: Size(3, 4),
          resolution: Size(1000, 1000),
          isPrimary: false,
          devicePixelRatio: 2,
        ),
      );
    },
  );

  test(
    'copyWith null',
    () {
      expect(
        data.copyWith(),
        data,
      );
    },
  );

  test(
    'hashCode',
    () {
      expect(
        data.hashCode,
        data.displays.fold(
          0,
          (previousValue, element) => previousValue.hashCode ^ element.hashCode,
        ),
      );
    },
  );
}
