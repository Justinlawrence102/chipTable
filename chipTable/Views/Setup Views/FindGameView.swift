//
//  FindGameView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

struct FindGameView: View {
    @EnvironmentObject var gameManager: PlayerGame
    @State private var isStartingGame = false
#if !os(tvOS)
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    #endif
    var body: some View {
        VStack {
            Text("Find Games")
                .font(.title2.weight(.semibold))
            .foregroundColor(Color("Text"))
            
            ForEach(gameManager.availableGames, id: \.self)  {
                peerId in
                SecondaryButtonView(title: peerId.displayName, action: {
                    _ in
                    #if os(visionOS)
                    gameManager.didSelectGame(gameId: peerId)
                    openWindow(id: "GameTable")
                    isStartingGame.toggle()
                    #else
                    gameManager.didSelectGame(gameId: peerId)
                    isStartingGame.toggle()
                    #endif
                })
            }
            VStack {
                ProgressView()
                    .scaleEffect(2)
                Text("Looking for games")
                    .foregroundColor(Color("Red"))
                    .padding(.top, 12.0)
            }
            .padding(.top, 20.0)
            Spacer()
            bottomCardView()
        }
        .overlay(alignment: .topTrailing) {
#if !os(tvOS)
            xButton(dismiss: _dismiss)
            #endif
        }
        .padding(.all)
        .fullScreenCover(isPresented: $isStartingGame) {
#if os(visionOS)
            GameTableView()
#else
            PlayerHandWaitingView()
#endif
        }
    }
}

struct FindGameView_Previews: PreviewProvider {
    static var previews: some View {
        FindGameView()
            .environmentObject(PlayerGame())
    }
}
