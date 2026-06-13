import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    print("🚀 APP DELEGATE CALLED")

    let result = GMSServices.provideAPIKey("AIzaSyBTkhSkL9nyLR_NH5zJFEw-0X-bVg1jp_0")
    print("Google Maps Key Result: \(result)")

    GeneratedPluginRegistrant.register(with: self)

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}