//
//  NetworkService.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import Foundation
import UIKit
import Alamofire

struct APIPost: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

class NetworkService {
    
    static let shared = NetworkService()
    
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    // Переменные для умной проверки сети
    private var lastNetworkCheck: Date?
    private var lastNetworkStatus: Bool?
    private let networkCheckInterval: TimeInterval = 5.0 // 5 секунд
    
    private init() {}

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let url = "\(baseURL)/posts"
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: [APIPost].self) { response in
                switch response.result {
                case .success(let apiPosts):
                    // Конвертируем APIPost в Post
                    let posts = apiPosts.map { apiPost in
                        Post(id: apiPost.id,
                             title: apiPost.title,
                             body: apiPost.body,
                             isLiked: false)
                    }
                    completion(.success(posts))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    // Загрузка аватара
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let image = UIImage(data: data)
                    completion(image)
                case .failure:
                    completion(nil)
                }
            }
    }
    // Умная проверка соединения с интервалом
    func isNetworkReachable() -> Bool {
        let now = Date()
        
        // Если это первая проверка или прошло больше 5 секунд
        if lastNetworkCheck == nil || now.timeIntervalSince(lastNetworkCheck!) >= networkCheckInterval {
            let currentStatus = NetworkReachabilityManager()?.isReachable ?? false
            
            // Если статус изменился или это первая проверка
            if lastNetworkStatus == nil || lastNetworkStatus != currentStatus {
                lastNetworkStatus = currentStatus
                lastNetworkCheck = now
                return currentStatus
            } else {
                // Статус не изменился, обновляем время проверки
                lastNetworkCheck = now
                return currentStatus
            }
        }
        
        // Возвращаем последний известный статус
        return lastNetworkStatus ?? false
    }
    
    // Принудительная проверка сети (для pull-to-refresh)
    func forceNetworkCheck() -> Bool {
        let currentStatus = NetworkReachabilityManager()?.isReachable ?? false
        lastNetworkStatus = currentStatus
        lastNetworkCheck = Date()
        return currentStatus
    }
} 
