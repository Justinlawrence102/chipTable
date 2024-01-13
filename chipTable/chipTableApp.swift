//
//  chipTableApp.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

@main
struct chipTableApp: App {
    @ObservedObject var gameManager = PlayerGame()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(gameManager)
        }
        
        #if os(visionOS)
        WindowGroup(id: "GameTable") {
            PlayerHandWaitingView()
                .environmentObject(gameManager)
        }
        .defaultSize(width: 150, height: 800)
//        .windowStyle(.volumetric)
        #endif
    }
}
