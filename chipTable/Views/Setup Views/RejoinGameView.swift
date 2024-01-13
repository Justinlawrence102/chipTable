//
//  RejoinGameView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/24.
//

import SwiftUI

struct RejoinGameView: View {
    @EnvironmentObject var gameManager: PlayerGame
    @State private var isStartingGame = false
#if !os(tvOS)
    @Environment(\.dismiss) var dismiss
    @Environment(\.openWindow) private var openWindow
#endif

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
#if !os(tvOS)
                    xButton(dismiss: _dismiss)
#endif
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
#if os(visionOS)
                                        gameManager.rejoinGame(player: player)
                                        openWindow(id: "GameTable")
                                        isStartingGame.toggle()
#else
                                        gameManager.rejoinGame(player: player)
                                        isStartingGame.toggle()
#endif
                                        
                                        
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
#if os(visionOS)
                            .frame(width: 300, height: 60)
#else
                            .foregroundColor(Color("Light Blue"))
                            .font(.body)
                            .frame(width: 350, height: 55)
                            .background(Color("Card"))
                            .cornerRadius(12)
#endif
                    })
#if os(visionOS)
                    .background(.thinMaterial)
                    .cornerRadius(28)
#endif
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
#if os(visionOS)
                GameTableView()
#else
                PlayerHandWaitingView()
#endif
            }
        }
    }
}

struct RejoinGameView_Previews: PreviewProvider {
    static var previews: some View {
        RejoinGameView()
            .environmentObject(PlayerGame())
    }
}

