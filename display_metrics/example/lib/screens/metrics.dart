import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/material.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  bool _isInitializing = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // call DisplayMetrics.ensureInitialized(context) to ensure
    // DisplayMetricsData has been loaded
    DisplayMetrics.ensureInitialized(context)?.then((data) {
      if (_isInitializing) {
        debugPrint('DisplayMetrics initialized with data [$data]');
        setState(() {
          _isInitializing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if you want, you can show loading widget
    // while DisplayMetrics is initializing
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // call DisplayMetrics.maybeOf(context)
    // or DisplayMetrics.of(context)
    // to get DisplayMetricsData
    final metrics = DisplayMetrics.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display metrics example app'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          DisplayInfoWidget(metrics: metrics),
          RealWidthWidget(
            label: 'real 1 inch',
            // call context.inchesToPixels(inches) to convert
            // inches into logical pixels
            width: context.inchesToPixels(1),
          ),
          RealWidthWidget(
            label: 'real 1 mm',
            // call context.mmToPixels(mm) to convert
            // millimeters into logical pixels
            width: context.mmToPixels(1),
          ),
          const SizedBox(height: 8),
          UnconstrainedBox(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/ruler'),
              child: const Text('Open Ruler'),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayInfoWidget extends StatelessWidget {
  const DisplayInfoWidget({
    required this.metrics,
    super.key,
  });

  final DisplayMetricsData metrics;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricsLabel(
              title: 'ppi',
              value: metrics.ppi.toStringAsFixed(0),
            ),
            MetricsLabel(
              title: 'devicePixelRatio',
              value: metrics.devicePixelRatio.toStringAsFixed(0),
            ),
            MetricsLabel(
              title: 'inchesToLogicalPixelRatio',
              value: metrics.inchesToLogicalPixelRatio.toStringAsFixed(0),
            ),
            MetricsLabel(
              title: 'diagonal (inches)',
              value: metrics.diagonal.toStringAsFixed(2),
            ),
            MetricsLabel(
              title: 'physicalSize (inches)',
              value: '${metrics.physicalSize.width.toStringAsFixed(2)} (w) x '
                  '${metrics.physicalSize.height.toStringAsFixed(2)} (h)',
            ),
            MetricsLabel(
              title: 'resolution (pixels)',
              value: '${metrics.resolution.width.toStringAsFixed(0)} (w) x '
                  '${metrics.resolution.height.toStringAsFixed(0)} (h)',
            ),
          ],
        ),
      ),
    );
  }
}

class RealWidthWidget extends StatelessWidget {
  const RealWidthWidget({
    required this.label,
    required this.width,
    super.key,
  });

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(label),
          const Icon(Icons.keyboard_double_arrow_right_rounded, size: 16),
          Container(
            width: width,
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class MetricsLabel extends StatelessWidget {
  const MetricsLabel({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$title: ',
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
