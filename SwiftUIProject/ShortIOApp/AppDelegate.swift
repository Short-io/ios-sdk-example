import Foundation
import SwiftUI
import ShortIOSDK


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let sdk = ShortIOSDK.shared

        // Short.io public key and domain. Both ship inside the client app by design.
        sdk.initialize(apiKey: "your_public_apiKey", domain: "yourshortdomain.short.gy")

        // Override point for customization after application launch.
        return true
    }

}

