import Flutter
import UIKit
import UIScreenExtension

public class DisplayMetricsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "display_metrics", binaryMessenger: registrar.messenger())
        let instance = DisplayMetricsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func getSize() -> [String: CGFloat] {
        let screenRect = UIScreen.dimensionInInches
        let screenWidth = screenRect?.width
        let screenHeight = screenRect?.height
        return ["Width": screenWidth ?? 0, "Height": screenHeight ?? 0]
    }
    
    func getResolution() -> [String: CGFloat] {
        let screenRect = UIScreen.main.nativeBounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        return ["Width": screenWidth, "Height": screenHeight]
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
