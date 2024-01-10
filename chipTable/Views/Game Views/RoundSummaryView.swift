//
//  RoundSummaryView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/7/23.
//

import SwiftUI

#if os(tvOS)
struct RoundSummaryView: View {
    @ObservedObject var game: Game
    var body: some View {
        VStack(spacing: 12.0) {
            Text("Round Summary")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(Color("Text"))
            HStack {
                Text("Player")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color("Text"))
                Spacer()
                Text("Chips Remaining")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color("Text"))
            }
            ForEach(game.players) {
                player in
                HStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(player.color)
                    Text(player.name)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Text(String(player.chipsRemaining))
                        .font(.headline.weight(.semibold))
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
            .buttonStyle(.card)
        }
        .frame(maxWidth: 600)
        .padding([.leading, .bottom, .trailing])
        .padding(.top, -25)
    }
}
#else
struct RoundSummaryView: View {
    @ObservedObject var game: Game
    var body: some View {
        VStack(spacing: 12.0) {
            Text("Round Summary")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(Color("Text"))
            HStack {
                Text("Player")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color("Text"))
                Spacer()
                Text("Chips Remaining")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color("Text"))
            }
            ForEach(game.players) {
                player in
                HStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(player.color)
                    Text(player.name)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Text(String(player.chipsRemaining))
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color("Red"))
                }
            }
            Spacer()
            Button(action: {
                print("Select winner!")
                game.goToNextRound()
                game.showingWinnerSelectModal = false
            }) {
                Text("Next Round")
            }
            .buttonStyle(PrimaryButton())
        }
        .padding([.leading, .bottom, .trailing])
        .padding(.top, -25)
    }
}
#endif
struct RoundSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RoundSummaryView(game: Game())
    }
}
