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

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(createShortLink), for: .touchUpInside)
        return button
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating Short Link..."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGreen
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy Short Link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
        return button
    }()

    private let errorLabel: UILabel = {
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
        let loaderStack = UIStackView(arrangedSubviews: [activityIndicator, loadingLabel])
        loaderStack.axis = .vertical
        loaderStack.alignment = .center
        loaderStack.spacing = 8

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            createButton,
            loaderStack,
            resultLabel,
            copyButton,
            errorLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            createButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            copyButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }

    @objc private func copyToClipboard() {
        guard let text = resultLabel.text?.replacingOccurrences(of: "Short URL: ", with: "") else { return }
        UIPasteboard.general.string = text

        let alert = UIAlertController(title: "Copied", message: "Short URL copied to clipboard.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func createShortLink() {
        resultLabel.text = nil
        errorLabel.text = nil
        copyButton.isHidden = true
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        createButton.isEnabled = false

        let parameters: ShortIOParameters
        do {
            parameters = try ShortIOParameters(
                domain: "your_domain",
                originalURL: "your_original_url"
            )
        } catch {
            activityIndicator.stopAnimating()
            loadingLabel.isHidden = true
            createButton.isEnabled = true
            errorLabel.text = "Invalid input: \(error.localizedDescription)"
            return
        }

        let apiKey = "your_api_key"

        Task { @MainActor in
            do {
                let result = try await shortLinkSDK.createShortLink(parameters: parameters, apiKey: apiKey)
                switch result {
                case .success(let response):
                    resultLabel.text = "Short URL: \(response.shortURL)"
                    copyButton.isHidden = false
                case .failure(let errorResponse):
                    errorLabel.text = "Error: \(errorResponse.message)"
                }
            } catch {
                errorLabel.text = "Error: \(error.localizedDescription)"
            }
            activityIndicator.stopAnimating()
            loadingLabel.isHidden = true
            createButton.isEnabled = true
        }
    }
}

