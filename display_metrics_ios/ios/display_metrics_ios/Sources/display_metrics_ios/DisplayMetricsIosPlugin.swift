import Flutter
import UIKit

public class DisplayMetricsIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "display_metrics", binaryMessenger: registrar.messenger())
      let instance = DisplayMetricsIosPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func getSize() -> [String: CGFloat] {
        let screenRect = UIScreen.dimensionInInches
        let screenWidth = screenRect?.width
        let screenHeight = screenRect?.height
        return ["width": screenWidth ?? 0, "height": screenHeight ?? 0]
    }
    
    func getResolution() -> [String: CGFloat] {
        let screenRect = UIScreen.main.nativeBounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        return ["width": screenWidth, "height": screenHeight]
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSize":
            let size = getSize()
            result(size)
        case "getResolution":
            let resolution = getResolution()
            result(resolution)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
