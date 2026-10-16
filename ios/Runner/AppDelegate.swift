import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let mapsRegistrar = self.registrar(forPlugin: "TaalaMaps")
    let mapsChannel = FlutterMethodChannel(
      name: "com.mintops.taala/maps",
      binaryMessenger: mapsRegistrar.messenger()
    )
    mapsChannel.setMethodCallHandler { call, result in
      if call.method == "googleMapsApiKey" {
        let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
        result(key)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
