# Flutter display_metrics plugin

The Flutter display_metrics plugin is build following the federated plugin architecture. A detailed explanation of the federated plugin concept can be found in the [Flutter documentation](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#federated-plugins). This means the display_metrics plugin is separated into the following packages:

1. [`display_metrics`][1]: the app facing package. This is the package users depend on to use the plugin in their project. For details on how to use the `display_metrics` plugin you can refer to its [README.md][2] file.
2. [`display_metrics_platform_interface`][3]: this packages declares the interface which all platform packages must implement to support the app-facing package. Instructions on how to implement a platform packages can be found in the [README.md][4] of the `display_metrics_platform_interface` package.

[1]: https://pub.dev/packages/display_metrics
[2]: ./display_metrics/README.md
[3]: https://pub.dev/packages/display_metrics_platform_interface
[4]: ./display_metrics_platform_interface/README.md