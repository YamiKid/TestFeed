//
//  AppDelegate.swift
//  TestFeed
//
//  Created by Maksim Kazushchik on 30.07.25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        window = UIWindow(frame: UIScreen.main.bounds)
        let feedViewController = FeedViewController()
        let navigationController = UINavigationController(rootViewController: feedViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
} 
