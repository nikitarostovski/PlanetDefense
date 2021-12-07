//
//  AppDelegate.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let game = GameViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = game
        window?.makeKeyAndVisible()
        
        return true
    }
}
