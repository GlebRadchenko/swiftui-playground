//
//  TestSwiftUIAppApp.swift
//  TestSwiftUIApp
//
//  Created by Gleb Radchenko on 24.11.20.
//

import SwiftUI

@main
struct TestSwiftUIAppApp: App {
    var body: some Scene {
        WindowGroup {
            LandmarkList()
                .environmentObject(UserData())
        }
    }
}
