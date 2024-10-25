import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/material.dart';

class DisplayMetricsTestWidget extends StatelessWidget {
  const DisplayMetricsTestWidget({
    this.onBuild,
    this.onError,
    super.key,
  });
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
