//
//  AppDelegate.swift
//  ApolloUnitTestingDemo
//
//  Created by Alexander Murphy on 12/8/18.
//  Copyright © 2018 Alexander Murphy. All rights reserved.
//

import UIKit
import Apollo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let coordinator = WorldCoordinator()


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = coordinator.nav
        
        return true
    }
}
