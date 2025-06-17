import SwiftUI
import ShortIOSDK


struct ContentView: View {
    @State private var shortURL: String?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    private let shortLinkSDK = ShortIOSDK()
    
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
            domain: "your_domain",
            originalURL: "https://{your_domain}"
        )
        let apiKey = "your_api_key"
        
        Task {
            do {
                let result = try await shortLinkSDK.createShortLink(
                    parameters: parameters,
                    apiKey: apiKey
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
}

#Preview {
    ContentView()
}
