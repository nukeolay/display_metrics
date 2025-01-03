#include "display_metrics_windows_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace display_metrics_windows {

	// static
	void DisplayMetricsWindowsPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar) {
		auto channel =
			std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
				registrar->messenger(), "display_metrics",
				&flutter::StandardMethodCodec::GetInstance());

		auto plugin = std::make_unique<DisplayMetricsWindowsPlugin>();

		channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		registrar->AddPlugin(std::move(plugin));
	}

	DisplayMetricsWindowsPlugin::DisplayMetricsWindowsPlugin() {}

	DisplayMetricsWindowsPlugin::~DisplayMetricsWindowsPlugin() {}

	void DisplayMetricsWindowsPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

		if (method_call.method_name() == "getSize") {
			auto size = DisplayMetricsWindowsPlugin::GetSize();
			flutter::EncodableMap response;
			response[flutter::EncodableValue("width")] = flutter::EncodableValue(size.first);
			response[flutter::EncodableValue("height")] = flutter::EncodableValue(size.second);
			result->Success(flutter::EncodableValue(response));
		}
		else if (method_call.method_name() == "getResolution") {
			auto resolution = DisplayMetricsWindowsPlugin::GetResolution();
			flutter::EncodableMap response;
			response[flutter::EncodableValue("width")] = flutter::EncodableValue(resolution.first);
			response[flutter::EncodableValue("height")] = flutter::EncodableValue(resolution.second);
			result->Success(flutter::EncodableValue(response));
		}
		else {
			result->NotImplemented();
		}
	}

	std::pair<double, double> DisplayMetricsWindowsPlugin::GetSize() {
		HDC hdc = GetDC(NULL);
		int mmWidth = GetDeviceCaps(hdc, HORZSIZE);
		int mmHeight = GetDeviceCaps(hdc, VERTSIZE);
		double widthInches = static_cast<double>(mmWidth) / 25.4;
		double heightInches = static_cast<double>(mmHeight) / 25.4;
		ReleaseDC(NULL, hdc);
		return { widthInches, heightInches };
	}

	std::pair<int, int> DisplayMetricsWindowsPlugin::GetResolution() {
		HDC hdc = GetDC(NULL);
		int width = GetDeviceCaps(hdc, HORZRES);
		int height = GetDeviceCaps(hdc, VERTRES);
		ReleaseDC(NULL, hdc);
		return { width, height };
	}

}
