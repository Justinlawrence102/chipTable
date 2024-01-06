//
//  RoundSummaryView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/7/23.
//

import SwiftUI

struct RoundSummaryView: View {
    @ObservedObject var game: Game
    var body: some View {
        VStack(spacing: 12.0) {
            Text("Round Summary")
                .font(Font.system(size: 30, weight: .semibold))
                .foregroundColor(Color("Blue"))
            HStack {
                Text("Player")
                    .font(Font.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("Blue"))
                Spacer()
                Text("Chips Remaining")
                    .font(Font.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("Blue"))
            }
            ForEach(game.players) {
                player in
                HStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(player.color)
                    Text(player.name)
                        .font(Font.system(size: 20, weight: .medium))
                        .foregroundColor(Color("Blue"))
                    Spacer()
                    Text(String(player.chipsRemaining))
                        .font(Font.system(size: 25, weight: .semibold))
                        .foregroundColor(Color("Red"))
                }
            }
            Spacer()
            Button(action: {
                print("Select winner!")
                game.goToNextRound()
                game.showingWinnerSelectModal = false
            }) {
                buttonView(title: "Next Round")
            }
        }
        .padding([.leading, .bottom, .trailing])
        .padding(.top, -25)
    }
}

struct RoundSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RoundSummaryView(game: Game())
    }
}
