//
//  CoreDataStack.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import CoreData
import Foundation

class CoreDataStack {
    
    static let shared = CoreDataStack()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestFeed")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    /// Основной контекст для UI операций
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Фоновый контекст для  фонового потока
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    private init() {}
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // В реальном приложении здесь должна быть обработка ошибок
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /**
     * Сохраняет изменения в фоновом контексте
     * 
     * Этот метод используется для сохранения изменений, сделанных
     * в фоновом контексте. Вызывается после операций записи
     * в фоновом потоке.
     */
    func saveBackgroundContext() {
        let context = persistentContainer.newBackgroundContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // В реальном приложении здесь должна быть обработка ошибок
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
} 
