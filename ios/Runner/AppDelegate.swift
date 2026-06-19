import Flutter
import UIKit
import GoogleMaps
import FirebaseCore      
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure() 
    print("🚀 APP DELEGATE CALLED")

    //let result = GMSServices.provideAPIKey("AIzaSyBTkhSkL9nyLR_NH5zJFEw-0X-bVg1jp_0")
    let result = GMSServices.provideAPIKey("AIzaSyCHPaQI4Y4Lm9NZdSXXt3W4l_qqKAHM5x0")
    print("Google Maps Key Result: \(result)")

    GeneratedPluginRegistrant.register(with: self)
    // Required for APNs token registration
    UNUserNotificationCenter.current().delegate = self
	Messaging.messaging().delegate = self

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
	
	func messaging(
		_ messaging: Messaging,
		didReceiveRegistrationToken fcmToken: String?
	) {
		print("🔥 Firebase registration token: \(fcmToken ?? "nil")")
	}

}
