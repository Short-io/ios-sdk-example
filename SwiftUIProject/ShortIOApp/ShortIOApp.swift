import SwiftUI
import ShortIOSDK

@main
struct ShortIOApp: App {
    
    var sdk = ShortIOSDK()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task{
                        await sdk.handleOpen(url) { result,destinationUrl, error  in
                            if let error = error {
                                    print("Error: \(error)")
                                    return
                                }

                            if let components = result {
                                print("Host: \(components.host ?? "nil")")
                                print("Path: \(components.path)")
                                print("DestinationUrl: \(destinationUrl ?? "nil")")
                            } else {
                                print("No components returned")
                            }
                        }
                    }
                }
        }
    }
}
