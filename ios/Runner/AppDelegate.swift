import UIKit
import Flutter
import Firebase

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {


    FirebaseApp.configure()   // <- Do this
    GeneratedPluginRegistrant.register(with: self) // <- Do this

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  
}
