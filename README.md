# 📱 ShortIOApp – iOS Sample Project for ShortIOSDK

**ShortIOApp** is a sample iOS project that demonstrates how to integrate and use the [ShortIOSDK](https://github.com/Short-io/ios-sdk) for generating short links and handling universal deep links using [Short.io](https://short.io/).

This project helps developers understand how to:

- Set up and use `ShortIOSDK`
- Generate short URLs with customizable parameters
- Integrate and handle Universal Links in SwiftUI and UIKit

## 📦 Requirements

- iOS 13.0+
- Xcode 13.0+
- Swift 5+
- A valid [Short.io](https://short.io/) account

## 🚀 Getting Started

### 📥 Clone the Repository

```bash
git clone https://github.com/Short-io/ios-sdk-example.git

# For SwiftUI project
cd ios-sdk-example/SwiftUIProject

# For Storyboard (UIKit) project
cd ios-sdk-example/StoryboardProject
```

### 📂 Open the Project

Open `ShortIOApp.xcodeproj` or `ShortIOApp.xcworkspace` in Xcode, depending on the structure.

## 🛠 Setup Instructions

### 🔑 1. Add Your API Key

Open the appropriate file:

- **SwiftUI:** `ContentView.swift`
- **UIKit:** `ViewController.swift`
Replace the placeholder with your **Short.io Public API Key:**

```bash
let apiKey = "your_api_key"
```

🔗 **Need help finding your API key?**

Follow this guide in the [ShortIOSDK README](https://github.com/Short-io/ios-sdk?tab=readme-ov-file#step-1-get-public-api-key-from-shortio).



### 🌐 2. Set Short Link Parameters

In the same file (`ContentView.swift` or `ViewController.swift`), provide your **Short.io domain** and the **original URL** you want to shorten:

```swift
let parameters = ShortIOParameters(
    domain: "your_domain", // e.g., example.short.gy
    originalURL: "https://{your_domain}" // The destination URL

)
```

## 💡 How It Works

The app demonstrates:

### ✅ Generating Short Links

Using your domain and original URL, you can generate a short link like this:

```swift
let sdk = ShortIOSDK()

let parameters = ShortIOParameters(
    domain: "your_domain",
    originalURL: "https://yourdomain.com"
)

let apiKey = "your_api_key"

Task {
    do {
        let result = try await sdk.createShortLink(parameters: parameters, apiKey: apiKey)
        switch result {
            case .success(let response):
                print("Short URL created: \(response.shortURL)")
            case .failure(let error):
                print("Error: \(error.message)")
        }
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

## 🌐 Handling Universal Links

### SwiftUI Implementation

Use the `.onOpenURL` modifier to process incoming links:

```swift
.onOpenURL { url in
    sdk.handleOpen(url) { result in
        print("Navigated to path: \(result?.path ?? "")")
    }
}
```

### UIKit Implementation

Handle incoming links by implementing the `scene(_:continue:)` method in the `SceneDelegate` file:

```swift
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL else {
            print("Invalid universal link or URL components")
            return
        }
        sdk.handleOpen(incomingURL) { result in
        print("Host: \(result?.host), Path: \(result?.path)")
    }
}
```

## 🤝 Contributing

If you'd like to contribute to the SDK or sample app, please fork the repository and submit a pull request.