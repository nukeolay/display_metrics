import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const data = DisplayMetricsData(
    physicalSize: Size(3, 4),
    resolution: Size(480, 640),
    devicePixelRatio: 1,
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
    'copyWith',
    () {
      expect(
        data.copyWith(
          devicePixelRatio: 2,
          physicalSize: const Size(10, 10),
          resolution: const Size(1000, 1000),
        ),
        const DisplayMetricsData(
          devicePixelRatio: 2,
          physicalSize: Size(10, 10),
          resolution: Size(1000, 1000),
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
        data.physicalSize.hashCode ^ data.resolution.hashCode,
      );
    },
  );

  test(
    'toString',
    () {
      expect(
        data.toString(),
        'ppi: ${data.ppi}, '
        'diaginal: ${data.diagonal} inches, '
        'physicalSize: ${data.physicalSize.width}x${data.physicalSize.height} inches, '
        'resolution: ${data.resolution.width}x${data.resolution.height} pixels',
      );
    },
  );
}
