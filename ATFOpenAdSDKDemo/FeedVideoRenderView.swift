import UIKit
import AVFoundation
import SDWebImage
import ATFOpenAdSDK

@objc class FeedVideoRenderView: FeedSelfRenderView {

    private let player: AVPlayer = {
        return AVPlayer()
    }()

    private let mediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let playerContainer: UIView = {
        let view = UIView()
      view.backgroundColor = .black
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 2
        return label
    }()

    

    private let gradientView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradient.locations = [0.5, 1.0]
        view.layer.addSublayer(gradient)
        view.isUserInteractionEnabled = false
        return view
    }()

    private weak var videoReporter: UnifiedAdVideoReporter?
    private var playerTimeObserver: Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

  isolated deinit {
    if let observer = playerTimeObserver {
      player.removeTimeObserver(observer)
    }
    NotificationCenter.default.removeObserver(self)
    player.pause()
  }

    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 12

        addSubview(playerContainer)
        addSubview(gradientView)
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(actionButton)

        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        playerContainer.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerContainer.topAnchor.constraint(equalTo: topAnchor),
            playerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            playerContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: descLabel.topAnchor, constant: -4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -8),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            actionButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = gradientView.bounds
        }
        if let playerLayer = playerContainer.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = playerContainer.bounds
        }
    }

    override public func configure(with adObject: UnifiedNativeAdObject) {
        super.configure(with: adObject)
        titleLabel.text = adObject.title
        descLabel.text = adObject.desc
      let buttonText = adObject.atfoAdButtonText ?? "查看详情"
      actionButton.setTitle(buttonText, for: .normal)
      actionButton.isHidden = false

        videoReporter = adObject.atfoVideoReporter

        if let videoInfo = adObject.videoInfo, let url = URL(string: videoInfo.videoURL) {
            setupVideoPlayer(with: url, duration: videoInfo.videoDuration)
        } else {
            setupStaticImage(with: adObject)
        }
    }

    private func setupVideoPlayer(with url: URL, duration: Int) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerContainer.layer.addSublayer(playerLayer)
        playerLayer.frame = playerContainer.bounds

        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        playerTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] _ in
        }

        player.play()
        videoReporter?.didStartPlayVideoWithVideoDuration?(TimeInterval(duration))
    }

    private func setupStaticImage(with adObject: UnifiedNativeAdObject) {
        if let mediaView = adObject.mediaView {
            playerContainer.addSubview(mediaView)
            self.sendSubviewToBack(playerContainer)
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: playerContainer.topAnchor),
                mediaView.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor),
                mediaView.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor),
            ])
            return
        }
        mediaImageView.removeFromSuperview()
        playerContainer.addSubview(mediaImageView)
        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaImageView.topAnchor.constraint(equalTo: playerContainer.topAnchor),
            mediaImageView.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor),
            mediaImageView.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor),
        ])
        
        let iconUrl = adObject.iconUrl
        if iconUrl.count > 0, let url = URL(string: iconUrl) {
            mediaImageView.sd_setImage(with: url, placeholderImage: nil)
        } else {
            let imageUrl = adObject.imageUrl
            if imageUrl.count > 0, let url = URL(string: imageUrl) {
                mediaImageView.sd_setImage(with: url, placeholderImage: nil)
            }
        }
    }

    @objc private func playerDidFinishPlaying() {
        videoReporter?.didFinishPlayingVideoatTime?(0)
        player.seek(to: .zero)
    }
}
