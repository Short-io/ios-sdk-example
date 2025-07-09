import UIKit
import ShortIOSDK

class ViewController: UIViewController {

    private let shortLinkSDK = ShortIOSDK()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Short Link Generator"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let createShortLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(createShortLink), for: .touchUpInside)
        return button
    }()

    private let createSecureShortLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Secure Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(createSecureShortLink), for: .touchUpInside)
        return button
    }()

    private let conversionTracking: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Conversion Tracking", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(trackingConversion), for: .touchUpInside)
        return button
    }()

    private let shortLinkActivityIndicator = UIActivityIndicatorView(style: .medium)
    private let secureLinkActivityIndicator = UIActivityIndicatorView(style: .medium)

    private let loadingShortLinkLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating Short Link..."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()
    
    private let loadingSecuredShortLinkLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating Secured Short Link..."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()

    private let resultShortLinkLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGreen
        return label
    }()

    private let resultSecureShortLinkLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGreen
        return label
    }()

    private let copyShortLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.tag = 1
        button.addTarget(self, action: #selector(copyToClipboard(_:)), for: .touchUpInside)
        return button
    }()

    private let copySecureShortLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy Secure Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.tag = 2
        button.addTarget(self, action: #selector(copyToClipboard(_:)), for: .touchUpInside)
        return button
    }()

    private let errorShortLinkLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        return label
    }()

    private let errorSecureShortLinkLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutUI()
    }

    private func layoutUI() {
        let shortLinkLoaderStack = UIStackView(arrangedSubviews: [shortLinkActivityIndicator, loadingShortLinkLabel])
        shortLinkLoaderStack.axis = .vertical
        shortLinkLoaderStack.alignment = .center
        shortLinkLoaderStack.spacing = 8

        let secureLinkLoaderStack = UIStackView(arrangedSubviews: [secureLinkActivityIndicator, loadingSecuredShortLinkLabel])
        secureLinkLoaderStack.axis = .vertical
        secureLinkLoaderStack.alignment = .center
        secureLinkLoaderStack.spacing = 8

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,

            createShortLinkButton,
            shortLinkLoaderStack,
            resultShortLinkLabel,
            copyShortLinkButton,
            errorShortLinkLabel,

            createSecureShortLinkButton,
            secureLinkLoaderStack,
            resultSecureShortLinkLabel,
            copySecureShortLinkButton,
            errorSecureShortLinkLabel,

            conversionTracking
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            createShortLinkButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            copyShortLinkButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            createSecureShortLinkButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            copySecureShortLinkButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            conversionTracking.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }


    @objc private func copyToClipboard(_ sender: UIButton) {
        let text: String?
        let message: String

        switch sender.tag {
        case 1:
            text = resultShortLinkLabel.text?.replacingOccurrences(of: "Short URL: ", with: "")
            message = "Short URL copied to clipboard."
        case 2:
            text = resultSecureShortLinkLabel.text?.replacingOccurrences(of: "Secured Short URL: ", with: "")
            message = "Secured Short URL copied to clipboard."
        default:
            return
        }

        guard let copiedText = text, !copiedText.isEmpty else { return }

        UIPasteboard.general.string = copiedText

        let alert = UIAlertController(title: "Copied", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func createShortLink() {
        resultShortLinkLabel.text = nil
        errorShortLinkLabel.text = nil
        copyShortLinkButton.isHidden = true
        shortLinkActivityIndicator.startAnimating()
        loadingShortLinkLabel.isHidden = false
        createShortLinkButton.isEnabled = false

        let parameters: ShortIOParameters
        do {
            parameters = try ShortIOParameters(
                domain: "your_domain",
                originalURL: "{https://{your_domain}"
            )
        } catch {
            shortLinkActivityIndicator.stopAnimating()
            createShortLinkButton.isEnabled = true
            errorShortLinkLabel.text = "Invalid input: \(error.localizedDescription)"
            return
        }

        let apiKey = "your_api_key"

        Task { @MainActor in
            do {
                let result = try await shortLinkSDK.createShortLink(parameters: parameters, apiKey: apiKey)
                switch result {
                case .success(let response):
                    resultShortLinkLabel.text = "Short URL: \(response.shortURL)"
                    copyShortLinkButton.isHidden = false
                case .failure(let errorResponse):
                    errorShortLinkLabel.text = "Error: \(errorResponse.message)"
                }
            } catch {
                errorShortLinkLabel.text = "Error: \(error.localizedDescription)"
            }
            shortLinkActivityIndicator.stopAnimating()
            createShortLinkButton.isEnabled = true
            loadingShortLinkLabel.isHidden = true
        }
    }

    @objc private func createSecureShortLink() {
        resultSecureShortLinkLabel.text = nil
        errorSecureShortLinkLabel.text = nil
        copySecureShortLinkButton.isHidden = true
        secureLinkActivityIndicator.startAnimating()
        loadingSecuredShortLinkLabel.isHidden = false
        createSecureShortLinkButton.isEnabled = false

        Task { @MainActor in
            do {
                let result = try await shortLinkSDK.createSecure(originalURL: "https://{your_domain}")
                resultSecureShortLinkLabel.text = "Secured Short URL: \(result.securedShortUrl)"
                copySecureShortLinkButton.isHidden = false
            } catch {
                errorSecureShortLinkLabel.text = "Error: \(error.localizedDescription)"
            }
            secureLinkActivityIndicator.stopAnimating()
            createSecureShortLinkButton.isEnabled = true
            loadingSecuredShortLinkLabel.isHidden = true
        }
    }

    @objc private func trackingConversion() {
        Task {
            do {
                let result = try await shortLinkSDK.trackConversion(originalURL: "https://{your_domain}", clid: "your_clid", conversionId: "your_coversionID")
                print("result", result)
            } catch {
                print("Failed to track conversion: \(error)")
            }
        }
    }
}
