//
//  PlayerPlayingView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI

struct PlayerPlayingView: View {
    @ObservedObject var playerGame: PlayerGame
    
    var body: some View {
        ZStack {
            VStack(spacing: 16.0) {
                Text("Current Bet")
                    .font(Font.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("Red"))
                Text(String(playerGame.currentBetOnTable))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Light Red"))
                
                PlayerChipCountView(player: playerGame.player)
                PrimaryButtonView(title: "Match Bet", action: {
                    _ in
                    playerGame.matchBet()
                })
                PrimaryButtonView(title: "Raise + 1", action: {
                    _ in
                    print("Raise 1")
                    playerGame.raise1()
                })
                Spacer()
                PrimaryButtonView(title: "Send Chips", action: {
                    _ in
                    print("Send Chips")
                    playerGame.sendChips()
                })
                
                SecondaryButtonView(title: "Fold", action: {
                    _ in
                    playerGame.fold()
                    print("Fold")
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 40.0)
            .padding(.vertical)
        }
        .background(Color("Blue"))
    }
}

struct PlayerChipCountView: View {
    @ObservedObject var player: Player
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(player.chipsRemaining))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Card"))
                    .cornerRadius(12)
                Text("Chips Remaining")
                    .font(Font.system(size: 18, weight: .regular))
                    .foregroundColor(Color("Light Red"))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text(String(player.currentBet))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Card"))
                    .cornerRadius(12)
                Text("My Bet")
                    .font(Font.system(size: 18, weight: .regular))
                    .foregroundColor(Color("Light Red"))
            }
        }
        .padding(.top)
    }
}

struct PlayerPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPlayingView(playerGame: PlayerGame(player: Player()))
    }
}
