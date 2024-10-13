import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:display_metrics/display_metrics.dart';

class DisplayMetricsTestWidget extends StatelessWidget {
  const DisplayMetricsTestWidget({this.onBuild, this.onError, super.key});
  final Function(BuildContext context)? onBuild;
  final Function(Object error)? onError;

  @override
  Widget build(BuildContext context) {
    try {
      onBuild?.call(context); // should fail
    } catch (error) {
      onError?.call(error);
    }
    return const SizedBox.shrink();
  }
}

class DisplayMetricsUpdateTestWidget extends StatefulWidget {
  const DisplayMetricsUpdateTestWidget({
    required this.initialData,
    required this.updatedData,
    required this.child,
    super.key,
  });
  final DisplayMetricsData initialData;
  final DisplayMetricsData updatedData;
  final Widget child;

  @override
  State<DisplayMetricsUpdateTestWidget> createState() =>
      _DisplayMetricsUpdateTestWidgetState();
}

class _DisplayMetricsUpdateTestWidgetState
    extends State<DisplayMetricsUpdateTestWidget> {
  late DisplayMetricsData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  void _updateData() {
    setState(() {
      _data = widget.updatedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetrics(
      data: _data,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _updateData,
            child: const Text('Update Data'),
          ),
          widget.child,
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const data = DisplayMetricsData(
    physicalSize: Size(3, 4),
    resolution: Size(480, 640),
    devicePixelRatio: 1,
  );

  testWidgets(
    'DisplayMetrics assert',
    (WidgetTester tester) async {
      late final AssertionError assertionError;

      await tester.pumpWidget(
        DisplayMetricsTestWidget(
          onBuild: DisplayMetrics.of,
          onError: (error) => assertionError = error as AssertionError,
        ),
      );

      expect(
        assertionError.message,
        'No DisplayMetrics found in context',
      );
    },
  );

  testWidgets(
    'DisplayMetrics maybeOf',
    (WidgetTester tester) async {
      late final DisplayMetricsData? displayMetricsData;

      await tester.pumpWidget(
        DisplayMetricsTestWidget(
          onBuild: (context) =>
              displayMetricsData = DisplayMetrics.maybeOf(context),
        ),
      );

      expect(displayMetricsData, null);
    },
  );

  testWidgets(
    'DisplayMetrics of',
    (WidgetTester tester) async {
      late final DisplayMetricsData displayMetricsData;

      final displayMetrics = DisplayMetrics(
        data: data,
        child: DisplayMetricsTestWidget(
          onBuild: (context) {
            displayMetricsData = DisplayMetrics.of(context);
          },
        ),
      );

      await tester.pumpWidget(displayMetrics);

      expect(displayMetricsData, data);
    },
  );

  testWidgets(
    'DisplayMetrics updateShouldNotify',
    (WidgetTester tester) async {
      DisplayMetricsData? displayMetricsData;
      final updatedData = data.copyWith(
        physicalSize: const Size(1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisplayMetricsUpdateTestWidget(
              initialData: data,
              updatedData: updatedData,
              child: DisplayMetricsTestWidget(
                onBuild: (context) =>
                    displayMetricsData = DisplayMetrics.of(context),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(displayMetricsData, updatedData);
    },
  );
}
