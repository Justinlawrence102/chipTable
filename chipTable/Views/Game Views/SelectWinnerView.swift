//
//  SelectWinnerView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/7/23.
//

import SwiftUI

struct SelectWinnerView: View {
    @ObservedObject var game: Game
    @State private var isShowingWinner = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12.0) {
                    Text("Select Winner")
                        .font(Font.system(size: 30, weight: .semibold))
                        .foregroundColor(Color("Blue"))
                    ForEach(game.players) {
                        player in
                        PrimaryButtonView(title: player.name, action: {
                            _ in
                            print("Select winner!")
                            game.selectWinner(player: player)
                            isShowingWinner.toggle()
                        })
                    }
                    Spacer()
                }
                .padding(.all)
                NavigationLink(destination: RoundSummaryView(game: game), isActive: $isShowingWinner) {EmptyView()}
            }
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("This is the detail view")
    }
}

struct SelectWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SelectWinnerView(game: Game())
    }
}
