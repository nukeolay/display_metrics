#ifndef FLUTTER_PLUGIN_DISPLAY_METRICS_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_DISPLAY_METRICS_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace display_metrics_windows {

	class DisplayMetricsWindowsPlugin : public flutter::Plugin {
	public:
		static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

		DisplayMetricsWindowsPlugin();

		virtual ~DisplayMetricsWindowsPlugin();

		// Disallow copy and assign.
		DisplayMetricsWindowsPlugin(const DisplayMetricsWindowsPlugin&) = delete;
		DisplayMetricsWindowsPlugin& operator=(const DisplayMetricsWindowsPlugin&) = delete;

		// Called when a method is called on this plugin's channel from Dart.
		void HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		static std::pair<double, double> GetSize();
		static std::pair<int, int> GetResolution();
		static void Log(const std::string& message);
	};

}  // namespace display_metrics_windows

#endif  // FLUTTER_PLUGIN_DISPLAY_METRICS_WINDOWS_PLUGIN_H_
