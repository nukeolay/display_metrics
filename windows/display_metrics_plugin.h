#ifndef FLUTTER_PLUGIN_DISPLAY_METRICS_PLUGIN_H_
#define FLUTTER_PLUGIN_DISPLAY_METRICS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace display_metrics {

	class DisplayMetricsPlugin : public flutter::Plugin {
	public:
		static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

		DisplayMetricsPlugin();

		virtual ~DisplayMetricsPlugin();

		DisplayMetricsPlugin(const DisplayMetricsPlugin&) = delete;
		DisplayMetricsPlugin& operator=(const DisplayMetricsPlugin&) = delete;

		void HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		static std::pair<double, double> GetSize();
		static std::pair<int, int> GetResolution();
		static void Log(const std::string& message);
	};

}

#endif
