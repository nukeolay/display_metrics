#include "include/display_metrics_windows/display_metrics_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "display_metrics_windows_plugin.h"

void DisplayMetricsWindowsPluginCApiRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	display_metrics_windows::DisplayMetricsWindowsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
