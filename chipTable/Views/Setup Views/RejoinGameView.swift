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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Find Games")
                        .font(.title2.weight(.semibold))
                    .foregroundColor(Color("Text"))
                    Spacer()
                }.overlay(alignment: .topTrailing) {
                    xButton(dismiss: _dismiss)
                }
                
                ForEach(gameManager.availableGames, id: \.self)  {
                    peerId in
                    NavigationLink(destination: {
                        VStack {
                            if let players = gameManager.players {
                                ForEach(players, id: \.self) {
                                    player in
                                    SecondaryButtonView(title: player, action: {
                                        _ in
                                        gameManager.rejoinGame(player: player)
                                        isStartingGame.toggle()
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
                        Text(peerId.displayName)
//#if os(visionOS)
//                            .frame(width: 300, height: 55)
//#endif
                    })
//#if os(visionOS)
//                    
//#else
                    .buttonStyle(SecondaryButtonStyle())
//#endif
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

