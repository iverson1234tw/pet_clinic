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
    GMSServices.provideAPIKey("AIzaSyBCFrp49Q41zzpp_Gx6QZu2nlV2r0VUe0w")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
