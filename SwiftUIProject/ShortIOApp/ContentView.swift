import SwiftUI
import ShortIOSDK


struct ContentView: View {
    @State private var shortURL: String?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var secureShortURL: String?
    private let shortLinkSDK = ShortIOSDK.shared // Ensure ShortLinkSDK is accessible

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Short Link Generator")
                .font(.title)
                .fontWeight(.bold)

            if isLoading {
                ProgressView("Creating short link...")
            } else {
                Button(action: createShortLink) {
                    Text("Create Short Link")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: createEncryptedLink) {
                    Text("Create Encrypted Short Link")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: conversionTracking) {
                    Text("Create conversion Tracking")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            if let shortURL = shortURL {
                Text("Short URL: \(shortURL)")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding()
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = shortURL
                        }) {
                            Text("Copy to Clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }

            if let secureShortURL = secureShortURL {
                Text("Secure Short URL: \(secureShortURL)")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding()
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = secureShortURL
                        }) {
                            Text("Copy to Clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }

            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }

    private func createShortLink() {
        isLoading = true
        shortURL = nil
        errorMessage = nil

        let parameters = ShortIOParameters(
            originalURL:"your-original-url-here"
        )

        Task {
            do {
                let result = try await shortLinkSDK.createShortLink(
                    parameters: parameters
                )
                switch result {
                case .success(let response):
                    shortURL = response.shortURL
                    print("Short URL created: \(response.shortURL)")
                case .failure(let errorResponse):
                    print("Error occurred: \(errorResponse.message), Code: \(errorResponse.code ?? "N/A")")
                    errorMessage = errorResponse.message
                }
                print("ress", result)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    private func createEncryptedLink() {
        Task {
            do {
                let result = try shortLinkSDK.createSecure(originalURL: "your_original_url")
                secureShortURL = result.securedOriginalURL
                print("result", result.securedOriginalURL, result.securedShortUrl)
            } catch {
                print("Failed to create secure URL: \(error)")
            }
        }
    }

    private func conversionTracking() {
        Task {
            do {
                let result = try await shortLinkSDK.trackConversion(clid: "your_clid", domain: "your_domain", conversionId: "your_conversion_id")
                print("result", result)
            } catch {
                print("Failed to track conversion: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
