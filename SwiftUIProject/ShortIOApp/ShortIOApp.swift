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
                    Task {
                        do {
                            let components = try await sdk.handleOpen(url)
                            print("Host: \(components.host ?? "nil")",
                                  "Path: \(components.path)",
                                  "QueryParams: \(components.queryItems ?? [])")
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
