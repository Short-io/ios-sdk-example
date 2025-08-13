import SwiftUI
import ShortIOSDK

@main
struct ShortIOApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var sdk = ShortIOSDK.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    sdk.handleOpen(url) { result in
                        switch result {
                        case .success(let result):
                            // Handle successful URL processing
                            print("result", result, "Host: \(result.host), Path: \(result.path)", "QueryParams: \(result.queryItems)")
                        case .failure(let error):
                            // Handle error with proper error type
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
