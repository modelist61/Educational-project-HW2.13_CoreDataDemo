//
//  AppDelegate.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 23.11.2020.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: TaskListViewController())
        
        return true
    }

    // MARK: - Core Data stack
    func applicationWillTerminate(_ application: UIApplication) { //сохранение при выгрузке APP
        StorageManager.share.saveContext()
    }
}

