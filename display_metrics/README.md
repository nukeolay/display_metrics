# display_metrics

Flutter plugin that provides display metrics such as real screen resolution, physical display size, ppi, diagonal. Also it contains BuildContext extension to transform inches & millimeters into Flutter logical pixels.

## Features

* Get real screen resolution, display size (inches) and PPI
* Convert inches and millimeters into Flutter logical pixels

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
<img src="https://raw.githubusercontent.com/nukeolay/display_metrics/main/display_metrics/example/example_1.png" alt="Example app" width="200"/>&nbsp;
<img src="https://raw.githubusercontent.com/nukeolay/display_metrics/main/display_metrics/example/example_2.png" alt="Ruler" width="200"/>

## Usage

### DisplayMetricsData

To access `DisplayMetricsData` you can call 
```dart
final metrics = DisplayMetrics.maybeOf(context);
// or
final metrics = DisplayMetrics.of(context);
```

```dart
// Device's primary screen physical size in inches
metrics.physicalSize => Size

// Device's primary screen resolution in real pixels
metrics.resolution => Size

// Device's primary screen diagonal in inches
metrics.diagonal => double

// Device's primary screen pixels per inch (PPI)
metrics.ppi => double 

// The number of logical pixels on the device's primary screen
// that corresponds to one inch
metrics.inchesToLogicalPixelRatio => double

// MediaQuery`s devicePixelRatio
metrics.devicePixelRatio => double

// List of all available displays metrics
metrics.displays => List<ExtendedPhysicalDisplayData>

// Display metrics data of promary display
metrics.primaryDisplay => ExtendedPhysicalDisplayData
```

You can await for `DisplayMetrics.ensureInitialized(context)` to ensure that `DisplayMetricsData` is available.

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
  child: child,
);
```

## Supported Platforms

| Platform | Support | Multi-Display |
|----------|:-------:|:-------------:|
| iOS      | ✅ | ❌ |
| Android  | ✅ | ✅<br>please read<br>the [foldable devices](#foldable-devices) |
| Windows  | ✅ | ❌ |
| macOS    | ✅ | ❌ |
| Linux    | ✅ | ❌ |
| Web      | ✅<br>please read<br>the [limitations](#web-limitations) | ❌ |

## Web limitations

Due to browser limitations, it's not possible to accurately determine 
the physical screen dimensions or the actual DPI on 
the web platform. Browsers use a unit called a CSS pixel, which is not 
a physical pixel but a unit based on a reference pixel, 
defined as 1/96th of an inch. This system depends on the viewing angle of 
the device and varies across displays, making it impossible to obtain 
accurate physical measurements or DPI through web APIs. You can read more [here][1].

## Foldable devices

On Android, this package now supports foldable and multi-display devices. When used on a device like the Pixel Fold, the plugin can detect the current active display and report its correct size - whether folded or unfolded.

Additionally, the `displays` getter returns a list of all connected displays (including external displays, if present).

Please note:
* The display list may contain multiple entries depending on the device and configuration.
* Each display includes its resolution in pixels, DPI, and a flag indicating whether it's the primary display.
* Testing has been performed using the Pixel Fold emulator.
* This feature is currently only supported on Android. Other platforms will always return a single display representing the main screen.

## Credits

iOS implementation uses Jens Schwarzer's [UIScreenExtension][2]

[1]: https://stackoverflow.com/questions/21680629/getting-the-physical-screen-dimensions-dpi-pixel-density-in-chrome-on-androi
[2]: https://github.com/marchv/UIScreenExtension