import Foundation
import SwiftUI
import ShortIOSDK


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let sdk = ShortIOSDK.shared

        sdk.initialize(apiKey: "your-api-key-here", domain: "your-domain-here")

        // Override point for customization after application launch.
        return true
    }

}

