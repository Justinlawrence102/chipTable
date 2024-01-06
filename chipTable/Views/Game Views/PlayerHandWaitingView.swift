//
//  PlayerHandWaitingView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI

struct PlayerHandWaitingView: View {
    @ObservedObject var playerGame: PlayerGame
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack(spacing: 20.0) {
                    ForEach(0..<playerGame.getRowCount())
                    { i in
                        VStack(spacing: -61.0)
                        {
                            ForEach(playerGame.chipsOnTable[i]) {
                                chip in
                                ChipView(color: chip.color)
                            }
                            Spacer()
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        .rotationEffect(Angle(degrees: 180))
                    }.id(playerGame.rowCounter)
                }
            }
            
            VStack(spacing: 16.0){
                Text("Current Bet")
                    .font(Font.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("Red"))
                Text(String(playerGame.currentBetOnTable))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Light Red"))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all)
            Text("Waiting for \(playerGame.currentPlayer)")
                .font(Font.system(size: 24, weight: .semibold))
                .foregroundColor(Color("Light Red"))
            VStack{
                Spacer()
                Text(String(playerGame.player.chipsRemaining))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Card"))
                    .cornerRadius(12)
            }
        }
        .background(Color("Blue"))
        .fullScreenCover(isPresented: $playerGame.isYourTurn) {
            PlayerPlayingView(playerGame: playerGame)
        }
    }
}

struct PlayerHandWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHandWaitingView(playerGame: PlayerGame(player: Player()))
    }
}
