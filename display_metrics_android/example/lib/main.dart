import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:display_metrics_android/display_metrics_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DisplayMetricsAndroid _displayMetricsPlugin;
  Size? _resolution;
  String? _resolutionError;
  Size? _size;
  String? _sizeError;
  List<PhysicalDisplayData>? _displays;
  String? _displaysError;

  @override
  void initState() {
    super.initState();
    _displayMetricsPlugin = DisplayMetricsAndroid();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaQuery.of(context);
    _getResolution();
    _getSize();
    _getDisplays();
  }

  Future<void> _getResolution() async {
    try {
      final resolution = await _displayMetricsPlugin.getResolution();
      setState(() {
        _resolution = resolution;
        _resolutionError = null;
      });
    } on PlatformException {
      setState(() {
        _resolutionError = 'Failed to get screen resolution';
      });
    }
  }

  Future<void> _getSize() async {
    try {
      final size = await _displayMetricsPlugin.getSize();
      setState(() {
        _size = size;
        _sizeError = null;
      });
    } on PlatformException {
      setState(() {
        _sizeError = 'Failed to get screen size';
      });
    }
  }

  Future<void> _getDisplays() async {
    try {
      final displays = await _displayMetricsPlugin.getDisplays();
      setState(() {
        _displays = displays;
        _displaysError = null;
      });
    } on PlatformException {
      setState(() {
        _displaysError = 'Failed to get displays';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('display resolution: ${_resolution ?? _resolutionError}'),
            const Divider(),
            Text('display size: ${_size ?? _sizeError}'),
            const Divider(),
            const Text('displays:'),
            if (_displaysError != null)
              Text(
                _displaysError!,
                textAlign: TextAlign.center,
              ),
            if (_displays != null)
              ..._displays!.map(
                (display) => Text(
                  display.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
