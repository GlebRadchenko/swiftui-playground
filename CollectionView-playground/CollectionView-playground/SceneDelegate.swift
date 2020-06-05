//
//  SceneDelegate.swift
//  CollectionView-playground
//
//  Created by Gleb Radchenko on 04.06.20.
//  Copyright © 2020 Volkswagen AG. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ExampleView()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            contentView.provider.generateNewItems()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                contentView.provider.items.remove(at: 1)
//            }
//        }

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

