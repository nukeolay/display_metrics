import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:display_metrics/display_metrics.dart';
import 'package:display_metrics/data.dart';
import 'package:display_metrics/extension.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DisplayMetricsWidget(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Display metrics example app'),
          ),
          body: const BodyWidget(),
        ),
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = DisplayMetrics.maybeOf(context);
    if (metrics == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        DisplayInfoWidget(metrics: metrics),
        const Divider(),
        const Expanded(child: RulerWidget()),
      ],
    );
  }
}

class DisplayInfoWidget extends StatelessWidget {
  const DisplayInfoWidget({required this.metrics, super.key});
  final DisplayMetricsData? metrics;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('devicePixelRatio: ${metrics?.devicePixelRatio}'),
            Text(
                'inchToPixelRatio: ${metrics?.inchesToPixelRatio.toStringAsFixed(0)}'),
            Text('ppi: ${metrics?.ppi.toStringAsFixed(0)}'),
            Text('diagonal (inches): ${metrics?.diagonal.toStringAsFixed(2)}'),
            Text(
                'physicalSize (inches): ${metrics?.physicalSize.width.toStringAsFixed(2)} x ${metrics?.physicalSize.height.toStringAsFixed(2)}'),
            Text(
                'resolution (pixels): ${metrics?.resolution.width.toStringAsFixed(0)} x ${metrics?.resolution.height.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}

class RulerWidget extends StatefulWidget {
  const RulerWidget({super.key});

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget> {
  RulerUnits _selectedUnits = RulerUnits.inches;
  double _sliderValue = 0;
  double _maxSliderValue = 0;

  void _updateSelector(RulerUnits? value) {
    if (value == null || value == _selectedUnits) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedUnits = value;
    });
  }

  void _updateSliderValue(double value) {
    HapticFeedback.selectionClick();
    setState(() {
      _sliderValue = value;
    });
  }

  void _updateMaxSliderValue(double pixels) {
    if (_maxSliderValue == pixels) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(() {
          _maxSliderValue = pixels;
        });
      },
    );
  }

  double _convertPixels(double pixels) {
    return _selectedUnits == RulerUnits.inches
        ? context.pixelsToInches(pixels.toInt())
        : context.pixelsToCm(pixels.toInt());
  }

  String get _rulerLabel =>
      '${_convertPixels(_sliderValue).toStringAsFixed(2)} ${_selectedUnits.name}';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UnitSelector(
                  value: RulerUnits.inches,
                  selectedValue: _selectedUnits,
                  onChange: _updateSelector,
                ),
                UnitSelector(
                  value: RulerUnits.cm,
                  selectedValue: _selectedUnits,
                  onChange: _updateSelector,
                ),
                Expanded(
                  child: RulerSlider(
                    length: _sliderValue,
                    maxLength: _maxSliderValue,
                    onChange: _updateSliderValue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _updateMaxSliderValue(constraints.maxHeight);
                return Ruler(
                  label: _rulerLabel,
                  height: _sliderValue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UnitSelector extends StatelessWidget {
  const UnitSelector({
    required this.value,
    required this.selectedValue,
    required this.onChange,
    super.key,
  });

  final RulerUnits value;
  final RulerUnits selectedValue;
  final void Function(RulerUnits?) onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.name),
        Radio<RulerUnits>(
          value: value,
          groupValue: selectedValue,
          onChanged: onChange,
        ),
      ],
    );
  }
}

class Ruler extends StatelessWidget {
  const Ruler({required this.label, required this.height, super.key});
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: height,
            width: 50,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class RulerSlider extends StatelessWidget {
  const RulerSlider({
    required this.length,
    required this.maxLength,
    required this.onChange,
    super.key,
  });
  final double length;
  final double maxLength;
  final void Function(double) onChange;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: length,
      min: 0,
      max: maxLength,
      onChanged: onChange,
    );
  }
}

enum RulerUnits { inches, cm }
