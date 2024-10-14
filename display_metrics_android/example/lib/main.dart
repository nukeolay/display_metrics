import 'package:flutter/material.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _displayMetricsPlugin = DisplayMetricsAndroid();
    _getResolution();
    _getSize();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('display resolution: ${_resolution ?? _resolutionError}'),
              Text('display size: ${_size ?? _sizeError}'),
            ],
          ),
        ),
      ),
    );
  }
}
