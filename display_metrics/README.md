# display_metrics

Flutter plugin that provides display metrics such as real screen resolution, physical display size, ppi, diagonal. Also it contains BuildContext extension to transform inches & millimeters into Flutter logical pixels.

## Features

* Get real screen resolution, display size (inches) and PPI
* Convert inches and millimeters into Flutter logical pixels

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  display_metrics: ^0.5.0
```

In your library add the following import:

```dart
import 'package:display_metrics/display_metrics.dart';
```

## Getting started

```dart
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // add DisplayMetricsWidget to Widget tree above MaterialApp to use DisplayMetrics.of(context) and BuildContext extension methods
    return DisplayMetricsWidget(
      child: MaterialApp(
        home: Scaffold(
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
```
<img src="https://raw.githubusercontent.com/nukeolay/display_metrics/main/display_metrics/example/example_1.png" alt="Example app" width="200"/>
<img src="https://raw.githubusercontent.com/nukeolay/display_metrics/main/display_metrics/example/example_2.png" alt="Ruler" width="200"/>

## Usage

### DisplayMetricsData

To access DisplayMetricsData you can call 
```dart
final metrics = DisplayMetrics.maybeOf(context);
// or
final metrics = DisplayMetrics.of(context);
```

```dart
// Device's screen physical size in inches
metrics.physicalSize => Size

// Device's screen resolution in real pixels
metrics.resolution => Size

// Device's screen diagonal in inches
metrics.diagonal => double

// Device's screen pixels per inch (PPI)
metrics.ppi => double 

// The number of logical pixels on the device's screen
// that corresponds to one inch
metrics.inchesToLogicalPixelRatio => double 

// MediaQuery`s devicePixelRatio;
metrics.devicePixelRatio => double 
```

### Convert units
To convert inches and millimeters into Flutter logical pixels and vice versa you can call one of BuildContext extension methods:
```dart
// Converts inches to Flutter logical pixels
context.inchesToPixels(double inches);

// Converts millimeters to Flutter logical pixels
context.mmToPixels(double mm);

// Converts Flutter logical pixels into inches
context.pixelsToInches(int pixels);

// Converts Flutter logical pixels into millimeters
context.pixelsToMm(int pixels);
```

### DisplayMetricsWidget
```dart
// Add [DisplayMetricsWidget] to Widget tree above MaterialApp to use DisplayMetrics.of(context) and BuildContext extension methods
DisplayMetricsWidget(
  // Set [updateSizeOnRotate] to true if you need to update size when orientation of your device changes
  updateSizeOnRotate: true,
  child: child,
);
```

## Supported Platforms

| Platform | Support | 
|----------|:-------:|
| iOS      |✅|
| Android  |✅|
| Windows  |✅|
| Web      |✅<br>please read<br>[limitations](#limitations)|
| macOS    |🛠<br>(to be added)|
| Linux    |🛠<br>(to be added)|

## Limitations

Due to browser limitations, it's not possible to accurately determine 
the physical screen dimensions or the actual DPI on 
the web platform. Browsers use a unit called a CSS pixel, which is not 
a physical pixel but a unit based on a reference pixel, 
defined as 1/96th of an inch. This system depends on the viewing angle of 
the device and varies across displays, making it impossible to obtain 
accurate physical measurements or DPI through web APIs. You can read more [here][1].

## Credits

iOS implementation uses Jens Schwarzer's [UIScreenExtension][2]

[1]: https://stackoverflow.com/questions/21680629/getting-the-physical-screen-dimensions-dpi-pixel-density-in-chrome-on-androi
[2]: https://stackoverflow.com/questions/21680629/getting-the-physical-screen-dimensions-dpi-pixel-density-in-chrome-on-androi