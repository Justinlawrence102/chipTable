//
//  chipTableApp.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

@main
struct chipTableApp: App {    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        
        #if os(visionOS)
        WindowGroup(id: "GameTable") {
            GameRealityView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 12, height: 3, depth: 12, in: .inches)
        #endif
    }
}
