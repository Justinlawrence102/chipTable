//
//  FindGameView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

struct FindGameView: View {
    @ObservedObject var gameManager: PlayerGame
    @State private var isStartingGame = false
    @Environment(\.openWindow) private var openWindow
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
        .padding(.all)
        .fullScreenCover(isPresented: $isStartingGame) {
            PlayerHandWaitingView(playerGame: gameManager)
        }
    }
}

struct FindGameView_Previews: PreviewProvider {
    static var previews: some View {
        FindGameView(gameManager: PlayerGame(player: Player()))
    }
}
