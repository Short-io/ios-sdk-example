# 📱 ShortIOApp – iOS Sample Project for ShortIOSDK

[![CI](https://github.com/Short-io/ios-sdk-example/actions/workflows/ci.yml/badge.svg)](https://github.com/Short-io/ios-sdk-example/actions/workflows/ci.yml)

**ShortIOApp** is a sample iOS project that demonstrates how to integrate and use the [ShortIOSDK](https://github.com/Short-io/ios-sdk) for generating short links and handling universal deep links using [Short.io](https://short.io/).

This project helps developers understand how to:

- Generate short URLs with customizable parameters
- Handle deep links via Universal Links
- Track conversions
- Use secure (encrypted) short links

## 📦 Requirements

- iOS 15.0+ (ShortIOSDK floor; these sample apps target iOS 18.4)
- Xcode 16.0+
- Swift 6.0
- A valid `enterprises` [Short.io](https://short.io/) account

Both sample projects resolve [ShortIOSDK](https://github.com/Short-io/ios-sdk) `2.0.0`
via Swift Package Manager. No manual setup is needed; Xcode fetches it on first open.

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

Both sample apps ship with `your_public_apiKey` / `yourshortdomain.short.gy` placeholders in
`AppDelegate.swift`. Replace them with your own before running, or every request returns an
authentication error. See [Get Public API Key](https://github.com/Short-io/ios-sdk#get-public-api-key-from-shortio).



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
            conversionId: "your_conversionID" // optional
        )
        print("result", result)
    } catch {
        print("Failed to track conversion: \(error)")
    }
}
```

**⚠️ Note:** `conversionId` is optional. The `clid` is captured by `handleOpen(_:)` and the
domain by `initialize(apiKey:domain:)`, so neither needs to be passed.

**Deprecated in 2.0.0.** Use `trackConversion(conversionId:)` instead.
This overload still works and will be removed in future releases.

## 🌐 Handling Universal Links

**⚠️ Prerequisite:** Universal Links require the **Associated Domains** capability
(`applinks:yourshortdomain.short.gy`) and a matching `<TeamID>.<BundleID>` configured under
**Domain Settings → Deep links** on Short.io. This needs a **paid** Apple Developer
membership — free personal teams cannot provision Associated Domains. See the
[SDK README](https://github.com/Short-io/ios-sdk#-deep-linking-setup-universal-links-for-ios)
for the full setup.

Without that setup the callbacks below never fire. To exercise `handleOpen(_:)` on its own,
call it directly with a short link — it is a plain HTTPS request and needs no entitlement
(the SwiftUI sample's **Resolve Short Link** button does exactly this).

### SwiftUI Implementation

Use the `.onOpenURL` modifier to process incoming links:

```swift
.onOpenURL { url in
    Task {
        do {
            let components = try await sdk.handleOpen(url)
            // Handle successful URL processing
            print(
                "Original URL: \(components.url?.absoluteString ?? "unknown")",
                "Host: \(components.host ?? "nil"), Path: \(components.path)",
                "QueryParams: \(components.queryItems ?? [])"
            )
        } catch {
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
    Task {
        do {
            let components = try await sdk.handleOpen(incomingURL)
            // Handle successful URL processing
            print(
                "Original URL: \(components.url?.absoluteString ?? "unknown")",
                "Host: \(components.host ?? "nil"), Path: \(components.path)",
                "QueryParams: \(components.queryItems ?? [])"
            )
        } catch {
            // Handle error with proper error type
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

**⚠️ Deprecated in 2.0.0.** Use the `async` form above instead.
The completion-handler overload `handleOpen(_:completion:)` still works and will be
removed in future releases.

## 🤝 Contributing

If you'd like to contribute to the SDK or sample app, please fork the repository and submit a pull request.