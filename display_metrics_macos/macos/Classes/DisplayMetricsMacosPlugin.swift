import Cocoa
import FlutterMacOS

public class DisplayMetricsMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "display_metrics", binaryMessenger: registrar.messenger)
    let instance = DisplayMetricsMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getResolution":
            if let screen = NSScreen.main {
                let width = screen.frame.width * screen.backingScaleFactor
                let height = screen.frame.height * screen.backingScaleFactor
                result(["width": width, "height": height])
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Screen data unavailable", details: nil))
            }
        case "getSize":
            let sizeMM = CGDisplayScreenSize(CGMainDisplayID())
            if sizeMM.width > 0 && sizeMM.height > 0 {
                let widthInches = sizeMM.width / 25.4
                let heightInches = sizeMM.height / 25.4
                result(["width": widthInches, "height": heightInches])
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Screen size data unavailable", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
