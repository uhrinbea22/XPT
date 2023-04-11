import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
override func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:
Any]?
) -> Bool {
GMSServices.provideAPIKey("AIzaSyAv75pXV0Ye9qS3aDKCqGP8FEzDuB_3gHw")
GeneratedPluginRegistrant.register(with: self)
return super.application(application, didFinishLaunchingWithOptions:
launchOptions)
}

}
