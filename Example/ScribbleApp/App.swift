//
//  App.swift
//  ScribbleApp
//

import SwiftUI

@main
struct ScribbleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem { Label("SwiftUI", systemImage: "swift") }
                UIKitDemo()
                    .tabItem { Label("UIKit", systemImage: "rectangle.stack") }
            }
        }
    }
}
