import Flutter
import UIKit
import GoogleMaps // ✅ 引入 Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ 在這裡初始化 API Key
    GMSServices.provideAPIKey("AIzaSyCGyAztBP53ICXtnMEuYr1g4EbJ72ga3Ww")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
