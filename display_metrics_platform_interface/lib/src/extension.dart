import 'dart:developer';
import 'dart:ui';

/// Map? extension that provides method to parse it to Size?
extension MapX on Map? {
  /// method to parse Map? to Size?
  Size? toSize() {
    try {
      final size = switch (this) {
        {'width': 0, 'height': 0} => null,
        {'width': final num width, 'height': final num height} =>
          Size(width.toDouble(), height.toDouble()),
        _ => null
      };
      return size;
    } catch (error, stackTrace) {
      log(
        'Error parsing $this to Size\n'
        'error: $error, stackTrace: $stackTrace',
      );
      return null;
    }
  }
}
