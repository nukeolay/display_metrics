import 'package:display_metrics_platform_interface/display_metrics_platform_interface.dart';

/// Unknown display of iOS device
class IosUnknownDisplayInfo extends UnknownDisplayInfo {
  /// Unknown display of iOS device
  const IosUnknownDisplayInfo({
    required super.resolution,
    required super.isPrimary,
    required this.modelIdentifier,
  });

  /// Device model identifier, for example 'iPhone19,4'
  final String modelIdentifier;

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is IosUnknownDisplayInfo &&
      modelIdentifier == other.modelIdentifier;

  @override
  int get hashCode => super.hashCode ^ modelIdentifier.hashCode;

  @override
  String toString() => 'unknown display ('
      'iOS model identifier: $modelIdentifier, '
      'resolution: ${resolution.width.round()}x${resolution.height.round()})';
}
