//
//  RejoinGameView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/24.
//

import SwiftUI

struct RejoinGameView: View {
    @ObservedObject var gameManager: PlayerGame
    @State private var isStartingGame = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Find Games")
                    .font(Font.system(size: 24, weight: .semibold))
                .foregroundColor(Color("Blue"))
                
                ForEach(gameManager.availableGames, id: \.self)  {
                    peerId in
                    NavigationLink(destination: {
                        VStack {
                            if let players = gameManager.players {
                                ForEach(players, id: \.self) {
                                    player in
                                    Button(action: {
                                        gameManager.rejoinGame(player: player)
                                        isStartingGame.toggle()
                                    }, label: {
                                        buttonView(title: player)
                                    })
                                }
                            }else {
                                ProgressView()
                            }
                        }
                        .onAppear(){
                            gameManager.requestPlayerList(gameId: peerId)
                        }
                    }, label: {
                        buttonView(title: peerId.displayName, backgroundColor: Color("Card"), titleColor: Color("Light Blue"))
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
}

struct RejoinGameView_Previews: PreviewProvider {
    static var previews: some View {
        RejoinGameView(gameManager: PlayerGame(player: Player()))
    }
}

