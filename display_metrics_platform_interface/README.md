# display_metrics_platform_interface

A common platform interface for the [`display_metrics`][1] plugin.

This interface allows platform-specific implementations of the `display_metrics`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `display_metrics`, extend
[`DisplayMetricsPlatform`][2] with implementation that perform 
the platform-specific behavior, and when you register your plugin,
set the default `DisplayMetricsPlatform` by calling
the `DisplayMetricsPlatform.instance` setter.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: https://pub.dev/packages/display_metrics
[2]: lib/display_metrics_platform_interface.dart