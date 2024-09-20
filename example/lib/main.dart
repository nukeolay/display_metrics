// This Flutter app demonstrates how to use the display_metrics package
// to access display metrics and convert between logical pixels and real world units.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:display_metrics/display_metrics.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // add DisplayMetricsWidget to Widget tree above MaterialApp to use
    // DisplayMetrics.of(context) and BuildContext extension methods
    return DisplayMetricsWidget(
      // Set this to true if you need to update size when orientation of your device changes
      updateSizeOnRotate: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(
          useMaterial3: true,
        ).copyWith(
          colorScheme: const ColorScheme.light().copyWith(
            primary: Colors.purple,
            secondary: Colors.blue.shade700,
            onSecondary: Colors.white,
            surface: Colors.grey.shade200,
            onSurface: Colors.black,
          ),
        ),
        home: const Page(),
      ),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display metrics example app'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      body: const BodyWidget(),
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
          label: 'real 1 mm',
          // call context.mmToPixels(mm) to convert millimeters into logical pixels
          width: context.mmToPixels(1),
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
              title: 'ppi',
              value: '${metrics?.ppi.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'devicePixelRatio',
              value: '${metrics?.devicePixelRatio.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'inchesToLogicalPixelRatio',
              value: '${metrics?.inchesToLogicalPixelRatio.toStringAsFixed(0)}',
            ),
            MetricsLabel(
              title: 'diagonal (inches)',
              value: '${metrics?.diagonal.toStringAsFixed(2)}',
            ),
            MetricsLabel(
              title: 'physicalSize (inches)',
              value: '${metrics?.physicalSize.width.toStringAsFixed(2)} (w) x '
                  '${metrics?.physicalSize.height.toStringAsFixed(2)} (h)',
            ),
            MetricsLabel(
              title: 'resolution (pixels)',
              value: '${metrics?.resolution.width.toStringAsFixed(0)} (w) x '
                  '${metrics?.resolution.height.toStringAsFixed(0)} (h)',
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
            color: Theme.of(context).colorScheme.secondary,
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
              color: Theme.of(context).colorScheme.secondary,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DisplayMetrics.maybeOf(context);
    setState(() {
      _sliderValue = 0;
      _maxSliderValue = 0;
    });
  }

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
        // call context.pixelsToMm(pixels) to convert logical pixels into millimeters
        : context.pixelsToMm(pixels.toInt());
  }

  String get _rulerLabel =>
      '${_convertPixels(_sliderValue).toStringAsFixed(2)} ${_selectedUnits.name}';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
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
                  value: RulerUnits.mm,
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
        Text(
          value.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
              color: Theme.of(context).colorScheme.primary,
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

enum RulerUnits { inches, mm }
