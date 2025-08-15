# 📱 ShortIOApp – iOS Sample Project for ShortIOSDK

**ShortIOApp** is a sample iOS project that demonstrates how to integrate and use the [ShortIOSDK](https://github.com/Short-io/ios-sdk) for generating short links and handling universal deep links using [Short.io](https://short.io/).

This project helps developers understand how to:

- Generate short URLs with customizable parameters
- Handle deep links via Universal Links
- Track conversions
- Use secure (encrypted) short links

## 📦 Requirements

- iOS 13.0+
- Xcode 13.0+
- Swift 5+
- A valid `enterprises` [Short.io](https://short.io/) account

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

### Initialize the SDK

Before using any functionality, you must initialize the SDK using your API key and domain in `AppDelegate` as part of application(launchOptions) for a UIKit app, or the @main initialization logic for a SwiftUI app.



```swift
...
import ShortIOSDK
...

class AppDelegate: UIResponder, UIApplicationDelegate {
  ...
  func application(...) {
    ...
    let sdk = ShortIOSDK.shared

    sdk.initialize(apiKey: "your_apiKey_here", domain: "your_domain_here")
    ...
  }
  ...
}
```

**Note:** Both `apiKey` and `domain` are the required parameters.

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
let sdk = ShortIOSDK.shared

let parameters = ShortIOParameters(
    domain: "your_domain",
    originalURL: "https://{your_domain}"
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

**⚠️ Note**: Both `apiKey` and `domain` parameters is deprecated. Use the instance's configured API key instead. Call initialize(apiKey:domain:) before using this method

### 🔐 Secure Short Links (Encrypted)

If you want to encrypt the original URL, the SDK provides a `createSecure` function that uses AES-GCM encryption.

#### 🔧 Example

```swift
let sdk = ShortIOSDK.shared

Task {
    do {
        let result = try sdk.createSecure(originalURL: "your_originalURL_here")
        print("result", result.securedOriginalURL, result.securedShortUrl)
    } catch {
        print("Failed to create secure URL: \(error)")
    }
}
```
#### 🧾 Output Format

- **`securedOriginalURL:`** An encrypted URL like `shortsecure://<Base64EncodedData>?<Base64IV>`

- **`securedShortUrl:`** A Base64-encoded decryption key to be appended as a fragment (e.g. `#<key>`)

### 🔄 Conversion Tracking

Track conversions for your short links to measure campaign effectiveness. The SDK provides a simple method to record conversions.

```swift
import ShortIOSDK

let sdk = ShortIOSDK.shared

Task {
    do {
        let result = try await sdk.trackConversion(
            domain: "your_domain", // ⚠️ Deprecated (optional):
            clid: "your_clid", // ⚠️ Deprecated (optional):
            conversionId: "your_conversionID" (optional)
        )
        print("result", result)
    } catch {
        print("Failed to track conversion: \(error)")
    }
}
```

**⚠️ Note:** All three parameters — `domain`, `clid`, and `conversionId` — are optional.
- `domain` and `clid` are deprecated and may be removed in future versions.

## 🌐 Handling Universal Links

### SwiftUI Implementation

Use the `.onOpenURL` modifier to process incoming links:

```swift
.onOpenURL { url in
    print("url", url)
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
```

## 🤝 Contributing

If you'd like to contribute to the SDK or sample app, please fork the repository and submit a pull request.