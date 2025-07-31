//
//  PostView.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import UIKit

// Интерфейс для реализации нужного метода
protocol PostViewDelegate: AnyObject {
    func postView(_ postView: PostView, didTapLikeFor post: Post)
}

class PostView: UIView {
    
    // Делегат для обработки событий
    weak var delegate: PostViewDelegate?
    
    private var post: Post?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        
        containerView.addSubview(headerContainer)
        
        headerContainer.addSubview(avatarImageView)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(likeButton)
        
        containerView.addSubview(bodyLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Header
            headerContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -12),
            
            // Like
            likeButton.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Header Height
            headerContainer.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            headerContainer.bottomAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor),
            headerContainer.bottomAnchor.constraint(greaterThanOrEqualTo: likeButton.bottomAnchor),
            
            // Description
            bodyLabel.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // PostView
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8)
        ])
    }

    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    // Обработчик нажатия на кнопку лайка
    @objc private func likeButtonTapped() {
        guard let post = post else { return }
        delegate?.postView(self, didTapLikeFor: post)
    }
    
    // Этот метод заполняет все элементы данными

    func configure(with post: Post) {
        self.post = post
        
        titleLabel.text = post.title.capitalized
        bodyLabel.text = post.body
        likeButton.isSelected = post.isLiked
        
        // Загружаем аватар с сети работает только с VPN
        if let avatarURL = post.avatarURL {
            NetworkService.shared.loadImage(from: avatarURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }
    }
    
    // Обновляет состояние кнопки лайка
    func updateLikeState(isLiked: Bool) {
        likeButton.isSelected = isLiked
    }
} 
