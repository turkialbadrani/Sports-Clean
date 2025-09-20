import UIKit
import Flutter
import FirebaseCore           // ✅ بدل import Firebase
import UserNotifications      // (اختياري) إن كنت تستخدم FCM

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()                 // ✅ لازم قبل استخدام Firebase
    GeneratedPluginRegistrant.register(with: self)

    // (اختياري) إن كنت تستخدم FCM وتريد عرض الإشعارات في foreground
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
