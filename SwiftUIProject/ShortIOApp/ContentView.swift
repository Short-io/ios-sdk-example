import SwiftUI
import ShortIOSDK


struct ContentView: View {
    @State private var shortURL: String?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var secureShortURL: String?
    @State private var incomingLink: String = ""
    @State private var destinationURL: String?
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

                // Runs handleOpen(_:) on a pasted link — the same call a universal
                // link makes, minus the Associated Domains setup.
                TextField("https://yourshortdomain.short.gy/slug", text: $incomingLink)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(.horizontal)

                Button(action: resolveShortLink) {
                    Text("Resolve Short Link")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(incomingLink.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(incomingLink.isEmpty)
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
                Text("Secure Short Link: \(secureShortURL)")
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

            if let destinationURL = destinationURL {
                Text("Destination: \(destinationURL)")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding()
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

        // originalURL is the destination you want shortened, not your Short.io domain.
        let parameters = ShortIOParameters(
            originalURL: "https://example.com"
        )

        Task {
            do {
                let result = try await shortLinkSDK.createShortLink(
                    parameters: parameters
                )
                switch result {
                case .success(let response):
                    shortURL = response.shortURL
                case .failure(let errorResponse):
                    errorMessage = errorResponse.message
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func createEncryptedLink() {
        isLoading = true
        secureShortURL = nil
        errorMessage = nil

        Task {
            do {
                let secure = try shortLinkSDK.createSecure(originalURL: "https://example.com")

                // The ciphertext is what gets shortened; the key never reaches the server.
                let parameters = ShortIOParameters(originalURL: secure.securedOriginalURL)
                switch try await shortLinkSDK.createShortLink(parameters: parameters) {
                case .success(let response):
                    // securedShortUrl is the "#<key>" fragment the browser decrypts with.
                    secureShortURL = response.shortURL + secure.securedShortUrl
                case .failure(let errorResponse):
                    errorMessage = errorResponse.message
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func resolveShortLink() {
        destinationURL = nil
        errorMessage = nil

        guard let url = URL(string: incomingLink) else {
            errorMessage = "Not a valid URL"
            return
        }

        Task {
            do {
                let components = try await shortLinkSDK.handleOpen(url)
                destinationURL = components.url?.absoluteString ?? components.string
                print("Host: \(components.host ?? "nil")",
                      "Path: \(components.path)",
                      "QueryParams: \(components.queryItems ?? [])")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func conversionTracking() {
        Task {
            do {
                // clid is captured by handleOpen(_:), domain by initialize(apiKey:domain:)
                _ = try await shortLinkSDK.trackConversion(conversionId: "your_conversion_id")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
