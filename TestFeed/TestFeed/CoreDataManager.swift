//
//  CoreDataManager.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import CoreData
import Foundation

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let coreDataStack = CoreDataStack.shared
    
    private init() {}
    
    func savePosts(_ posts: [Post]) {
        let context = coreDataStack.backgroundContext
        
        context.perform {
            do {
                // Создаем новые записи PostEntity для каждого поста
                for post in posts {
                    let postEntity = NSEntityDescription.insertNewObject(forEntityName: "PostEntity", into: context)
                    postEntity.setValue(Int32(post.id), forKey: "postId")
                    postEntity.setValue(post.title, forKey: "postTitle")
                    postEntity.setValue(post.body, forKey: "postBody")
                    postEntity.setValue(post.isLiked, forKey: "isLiked")
                }
                
                // Сохраняем изменения в базе данных
                try context.save()
            } catch {
                print("Ошибка с сохранением постов в CoreData: \(error.localizedDescription)")
            }
        }
    }
    

    func loadPosts() -> [Post] {
        let context = coreDataStack.context
        
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        
        do {
            // Выполняем запрос и получаем PostEntity
            let postEntities = try context.fetch(fetchRequest)
            
            // Мапим сущности в наши модели Post
            let posts = postEntities.compactMap { entity -> Post? in
                guard
                    let title = entity.postTitle,
                    let body  = entity.postBody
                else {
                    return nil
                }
                
                return Post(
                    id:      Int(entity.postId),
                    title:   title,
                    body:    body,
                    isLiked: entity.isLiked
                )
            }
            
            return posts
            
        } catch {
            print("Ошибка загрузки постов: \(error)")
            return []
        }
    }

    
    // Обновляет состояние лайка для конкретного поста
    func updateLikeState(postId: Int, isLiked: Bool) {
        let context = coreDataStack.backgroundContext
        
        context.perform {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")
                fetchRequest.predicate = NSPredicate(format: "postId == %d", postId)
                
                let postEntities = try context.fetch(fetchRequest)
                if let post = postEntities.first {
                    post.setValue(isLiked, forKey: "isLiked")
                    try context.save()
                }
            } catch {
                print("Ошибка с обновлением лайка в CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    // Проверяет наличие кэшированных постов в CoreData
    func hasCachedPosts() -> Bool {
        let context = coreDataStack.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
}
