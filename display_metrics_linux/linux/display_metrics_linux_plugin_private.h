#include <flutter_linux/flutter_linux.h>

#include "include/display_metrics_linux/display_metrics_linux_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Handles the getPlatformVersion method call.
FlMethodResponse *get_resolution();
FlMethodResponse *get_physical_size();
