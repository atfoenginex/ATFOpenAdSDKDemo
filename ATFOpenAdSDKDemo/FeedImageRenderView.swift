import UIKit
import SDWebImage
import ATFOpenAdSDK

@objc class FeedImageRenderView: FeedSelfRenderView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.darkText
        label.numberOfLines = 1
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(actionButton)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            actionButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    override public func configure(with adObject: UnifiedNativeAdObject) {
        super.configure(with: adObject)
        titleLabel.text = adObject.title
        descLabel.text = adObject.desc
      let buttonText = adObject.atfoAdButtonText ?? "点击跳转"
      actionButton.setTitle(buttonText, for: .normal)
      actionButton.isHidden = false
      let iconUrl = adObject.iconUrl
        if iconUrl.count > 0, let url = URL(string: iconUrl) {
            imageView.sd_setImage(with: url, placeholderImage: nil)
        } else {
            let imageUrl = adObject.imageUrl
            if imageUrl.count > 0, let url = URL(string: imageUrl) {
                imageView.sd_setImage(with: url, placeholderImage: nil)
            }
        }
    }
}
