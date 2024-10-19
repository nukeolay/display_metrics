# display_metrics_web

The web implementation of [`display_metrics`][1].

## Usage

This package is [endorsed][2], which means you can simply use `display_metrics`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Limitations

Due to browser limitations, it's not possible to accurately determine 
the physical screen dimensions or the actual DPI on 
the web platform. Browsers use a unit called a CSS pixel, which is not 
a physical pixel but a unit based on a reference pixel, 
defined as 1/96th of an inch. This system depends on the viewing angle of 
the device and varies across displays, making it impossible to obtain 
accurate physical measurements or DPI through web APIs. You can read more [here][3].

[1]: https://pub.dev/packages/display_metrics
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://stackoverflow.com/questions/21680629/getting-the-physical-screen-dimensions-dpi-pixel-density-in-chrome-on-androi