//
//  FeedViewController.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import UIKit


class FeedViewController: UIViewController {
    
    // Массив постов для отображения в ленте
    private var posts: [Post] = []
    
    // Таймер для периодической проверки сети
    private var networkCheckTimer: Timer?
    private var hasShownOfflineAlert = false
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление...")
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRefreshControl()
        loadInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNetworkCheckTimer()
    }
    
    private func setupUI() {
        title = "Лента Постов"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Stack
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    // Загрузка данных сразу с кэша затем с сервера, если возможно
    private func loadInitialData() {
        loadPostsFromCache()
        
        // Первоначальная проверка сети
        if NetworkService.shared.isNetworkReachable() {
            loadPostsFromNetwork()
        } else {
            // Показываем алерт только при первом запуске, если нет сети
            showOfflineAlert()
            hasShownOfflineAlert = true
        }
        
        // Запускаем таймер для периодической проверки сети
        startNetworkCheckTimer()
    }
    
    // Загрузка постов из CoreData
    private func loadPostsFromCache() {
        let hasCached = CoreDataManager.shared.hasCachedPosts()
        
        if hasCached {
            let cachedPosts = CoreDataManager.shared.loadPosts()
            posts = cachedPosts
            updateUI()
        }
    }
    // Загрузка постов из API
    private func loadPostsFromNetwork() {
        NetworkService.shared.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let posts):
                    // Сохраняем новые данные в CoreData
                    CoreDataManager.shared.savePosts(posts)
                    
                    // Загружаем данные из CoreData
                    let cachedPosts = CoreDataManager.shared.loadPosts()
                    self?.posts = cachedPosts
                    
                    self?.updateUI()
                    
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    // pull-to-refresh
    @objc private func refreshData() {
        // Принудительная проверка сети для pull-to-refresh
        if NetworkService.shared.forceNetworkCheck() {
            loadPostsFromNetwork()
        } else {
            refreshControl.endRefreshing()
            showOfflineAlert()
        }
    }
    
    // Запуск таймера для периодической проверки сети
    private func startNetworkCheckTimer() {
        networkCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkNetworkAndUpdate()
        }
    }
    
    // Остановка таймера
    private func stopNetworkCheckTimer() {
        networkCheckTimer?.invalidate()
        networkCheckTimer = nil
    }
    
    // Проверка сети и обновление данных
    private func checkNetworkAndUpdate() {
        let isNetworkAvailable = NetworkService.shared.isNetworkReachable()
        
        if isNetworkAvailable {
            // Если сеть стала доступна и раньше не было данных
            if posts.isEmpty {
                loadPostsFromNetwork()
            }
            // Сбрасываем флаг показа офлайн алерта
            hasShownOfflineAlert = false
        } else {
            // Показываем алерт только если еще не показывали
            if !hasShownOfflineAlert {
                showOfflineAlert()
                hasShownOfflineAlert = true
            }
        }
    }

    private func updateUI() {
        // Удаляем все существующие PostView
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новые PostView для каждого поста
        if !posts.isEmpty {
            for post in posts {
                let postView = PostView()
                postView.delegate = self
                postView.configure(with: post)
                stackView.addArrangedSubview(postView)
            }
        }
    }
    
    // Показывает алерт с ошибкой загрузки
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить посты",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Показывает алерт с ошибкой сети
    private func showOfflineAlert() {
        let alert = UIAlertController(
            title: "Нет подключения",
            message: "Данные загружены из кэша. Приложение будет автоматически обновляться при восстановлении соединения.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

/**
 * Обрабатывает события от PostView
 * Обновляет данные и сохраняет изменения в CoreData.
 */
extension FeedViewController: PostViewDelegate {
    
    func postView(_ postView: PostView, didTapLikeFor post: Post) {
        var updatedPost = post
        updatedPost.isLiked = !post.isLiked
        
        // Обновляем пост в локальном массиве
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = updatedPost
        }
        
        // Обновляем UI
        postView.updateLikeState(isLiked: updatedPost.isLiked)
        
        // Сохраняем изменение в CoreData
        CoreDataManager.shared.updateLikeState(postId: post.id, isLiked: updatedPost.isLiked)
    }
} 
