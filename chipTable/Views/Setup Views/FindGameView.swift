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
    var body: some View {
        VStack {
            Text("Find Games")
                .font(Font.system(size: 24, weight: .semibold))
            .foregroundColor(Color("Blue"))
            
            ForEach(gameManager.availableGames, id: \.self)  {
                peerId in
                Button(action: {
                    gameManager.didSelectGame(gameId: peerId)
                    isStartingGame.toggle()
                }) {
                    buttonView(title: peerId.displayName, backgroundColor: Color("Card"), titleColor: Color("Light Blue"))
                }
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
