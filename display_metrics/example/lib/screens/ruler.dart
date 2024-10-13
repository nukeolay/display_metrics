import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RulerScreen extends StatelessWidget {
  const RulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruler'),
        centerTitle: true,
      ),
      body: const RulerWidget(),
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
        // call context.pixelsToInches(pixels) to convert
        // logical pixels into inches
        ? context.pixelsToInches(pixels.toInt())
        // call context.pixelsToMm(pixels) to convert
        // logical pixels into millimeters
        : context.pixelsToMm(pixels.toInt());
  }

  String get _rulerLabel =>
      '${_convertPixels(_sliderValue).toStringAsFixed(2)} '
      '${_selectedUnits.name}';

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
  const Ruler({
    required this.label,
    required this.height,
    super.key,
  });

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
