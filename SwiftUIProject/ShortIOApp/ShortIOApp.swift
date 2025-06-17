import SwiftUI
import ShortIOSDK

@main
struct ShortIOApp: App {
    
    var sdk = ShortIOSDK()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    sdk.handleOpen(url) { result in
                        print("Host: \(result?.host), Path: \(result?.path)")
                    }
                }
        }
    }
}
