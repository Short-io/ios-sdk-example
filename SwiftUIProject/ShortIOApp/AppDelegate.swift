import Foundation
import SwiftUI
import ShortIOSDK


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let sdk = ShortIOSDK.shared

        // Demo credentials. The API key is a Short.io *public* key, which is designed to ship
        // inside client apps — replace both with your own.
        sdk.initialize(apiKey: "pk_rmfLWoun5GDaCpAr", domain: "demodeeplinkapp.short.gy")

        // Override point for customization after application launch.
        return true
    }

}

