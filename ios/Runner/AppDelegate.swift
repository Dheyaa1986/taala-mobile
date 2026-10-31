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

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let registrar = self.registrar(forPlugin: "TaalaMaps") {
      let mapsChannel = FlutterMethodChannel(
        name: "com.mintops.taala/maps",
        binaryMessenger: registrar.messenger()
      )
      mapsChannel.setMethodCallHandler { call, result in
        if call.method == "googleMapsApiKey" {
          let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
          result(key)
        } else if call.method == "setMapLanguage" {
          let code = (call.arguments as? String) ?? "ar"
          let mapsLang = code.hasPrefix("en") ? "en" : "ar"
          UserDefaults.standard.set([mapsLang], forKey: "AppleLanguages")
          UserDefaults.standard.set(mapsLang, forKey: "AppleLocale")
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return launched
  }
}
