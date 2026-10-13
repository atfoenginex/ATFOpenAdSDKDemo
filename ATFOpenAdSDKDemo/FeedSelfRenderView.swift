import UIKit
import SDWebImage
import ATFOpenAdSDK

@objc public class FeedSelfRenderView: UIView {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
  
  private let logoLabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 11, weight: .light)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
  
  @objc
  public let actionButton: UIButton = {
      let button = UIButton(type: .system)
      button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
      button.backgroundColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
      button.setTitleColor(.white, for: .normal)
      button.layer.cornerRadius = 4
      button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
      return button
  }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(logoImageView)
      addSubview(logoLabel)
        addSubview(closeButton)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            logoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            logoImageView.widthAnchor.constraint(equalToConstant: 18),
            logoImageView.heightAnchor.constraint(equalToConstant: 18),
            logoLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            logoLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 0),
            logoLabel.heightAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 1),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
        ])
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var _onClose: (() -> Void)?

    @objc public func setOnClose(_ block: @escaping () -> Void) {
        _onClose = block
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(logoImageView)
      bringSubviewToFront(logoLabel)
        bringSubviewToFront(closeButton)
    }

    @objc private func didTapClose() {
        _onClose?()
    }

    @objc public func configure(with adObject: UnifiedNativeAdObject) {
        if let adLogoImageURL = adObject.adLogoImageURL,
           !adLogoImageURL.isEmpty,
           let url = URL(string: adLogoImageURL) {
            logoImageView.sd_setImage(with: url, placeholderImage: nil)
          logoLabel.backgroundColor = .black.withAlphaComponent(0.4)
          logoLabel.text = "广告"
        }
      if let logoView = adObject.adLogoView {
        addSubview(logoView)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
          [
            logoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            logoView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            logoView.heightAnchor.constraint(equalToConstant: 15),
            logoView.widthAnchor.constraint(equalToConstant: 40)
          ]
        )
      }
    }

    @objc public static func view(with adObject: UnifiedNativeAdObject) -> FeedSelfRenderView {
        switch adObject.atfoMaterialType {
        case .singleImage, .multiImage:
            return FeedImageRenderView()
        case .video:
            return FeedVideoRenderView()
        @unknown default:
            return FeedImageRenderView()
        }
    }
  
  deinit {
    print("======")
  }
}
