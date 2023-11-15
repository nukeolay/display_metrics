// This Flutter app demonstrates how to use the display_metrics package
// to access display metrics and convert between logical pixels and real world units.

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
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      // add DisplayMetricsWidget to Widget tree under MaterialApp to use
      // DisplayMetrics.of(context) and BuildContext extension methods
      home: DisplayMetricsWidget(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Display metrics example app'),
            centerTitle: true,
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
    // call DisplayMetrics.maybeOf(context) or DisplayMetrics.of(context)
    // to get DisplayMetricsData
    final metrics = DisplayMetrics.maybeOf(context);
    if (metrics == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayInfoWidget(metrics: metrics),
        RealWidthWidget(
          label: 'real 1 inch',
          // call context.inchesToPixels(inches) to convert inches into logical pixels
          width: context.inchesToPixels(1),
        ),
        RealWidthWidget(
          label: 'real 1 cm',
          // call context.cmToPixels(cm) to convert centimeters into logical pixels
          width: context.cmToPixels(1),
        ),
        const SizedBox(height: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricsLabel(
              title: 'devicePixelRatio',
              value: '${metrics?.devicePixelRatio.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'inchToPixelRatio',
              value: '${metrics?.inchesToPixelRatio.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'ppi',
              value: '${metrics?.ppi.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'diagonal (inches)',
              value: '${metrics?.diagonal.toStringAsFixed(2)}',
            ),
            MetricsLabel(
              title: 'physicalSize (inches)',
              value:
                  '${metrics?.physicalSize.width.toStringAsFixed(2)} x ${metrics?.physicalSize.height.toStringAsFixed(2)}',
            ),
            MetricsLabel(
              title: 'resolution (pixels)',
              value:
                  '${metrics?.resolution.width.toStringAsFixed(0)} x ${metrics?.resolution.height.toStringAsFixed(0)}',
            ),
          ],
        ),
      ),
    );
  }
}

class RealWidthWidget extends StatelessWidget {
  const RealWidthWidget({required this.label, required this.width, super.key});
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
            color: _accentColor,
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
              color: _accentColor,
            ),
          ),
        ],
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
        // call context.pixelsToInches(pixels) to convert logical pixels into inches
        ? context.pixelsToInches(pixels.toInt())
        // call context.pixelsToCm(pixels) to convert logical pixels into centimeters
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
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 8,
              left: 8,
              right: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              padding: const EdgeInsets.all(8),
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: _accentColor,
            ),
          ),
          if (height != 0)
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

Color _accentColor = const Color(0xFF381E72);
