import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var mapsSdkReady = false
  private var mapsChannelRetries = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let apiKey = readGoogleMapsApiKey()
    if !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
      mapsSdkReady = true
    }

    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    setupMapsChannel()
    return launched
  }

  private func mapsMessenger() -> FlutterBinaryMessenger? {
    if let controller = window?.rootViewController as? FlutterViewController {
      return controller.binaryMessenger
    }
    return registrar(forPlugin: "TaalaMapsChannel")?.messenger()
  }

  private func setupMapsChannel() {
    guard let messenger = mapsMessenger() else {
      if mapsChannelRetries < 20 {
        mapsChannelRetries += 1
        DispatchQueue.main.async { [weak self] in
          self?.setupMapsChannel()
        }
      }
      return
    }

    let mapsChannel = FlutterMethodChannel(
      name: "com.mintops.taala/maps",
      binaryMessenger: messenger
    )
    mapsChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }
      switch call.method {
      case "googleMapsApiKey":
        result(self.readGoogleMapsApiKey())
      case "mapsSdkReady":
        result(self.mapsSdkReady)
      case "setMapLanguage":
        // Do not change AppleLanguages; it relaunches or crashes some iPhones.
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func readGoogleMapsApiKey() -> String {
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty && !trimmed.contains("GOOGLE_MAPS_API_KEY") {
        return trimmed
      }
    }
    if let path = Bundle.main.path(forResource: "GoogleMapsApiKey", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path),
       let key = dict["GMSApiKey"] as? String {
      let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }
    return ""
  }
}
