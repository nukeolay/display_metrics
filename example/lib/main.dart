// This Flutter app demonstrates how to use the display_metrics package
// to access display metrics and convert between logical pixels and real world units.

import 'package:display_metrics_example/screens/metrics.dart';
import 'package:display_metrics_example/screens/ruler.dart';
import 'package:flutter/material.dart';

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
            primary: Colors.blue,
            secondary: Colors.blue.shade900,
            onSecondary: Colors.white,
            surface: Colors.grey.shade200,
            onSurface: Colors.black,
          ),
        ),
        routes: {
          '/': (_) => const MetricsScreen(),
          '/ruler': (_) => const RulerScreen(),
        },
      ),
    );
  }
}

