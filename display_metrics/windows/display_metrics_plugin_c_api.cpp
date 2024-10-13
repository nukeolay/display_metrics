#include "include/display_metrics/display_metrics_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "display_metrics_plugin.h"

void DisplayMetricsPluginCApiRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	display_metrics::DisplayMetricsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
