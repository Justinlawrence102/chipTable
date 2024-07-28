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
    @State private var isSelectingNextWinner = false
    @State var chipGroupIndex = 0
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12.0) {
                    Text("Select Winner")
                        .font(Font.system(size: 30, weight: .semibold))
                        .foregroundColor(Color("Text"))
                    ForEach(game.players) {
                        player in
                        PrimaryButtonView(title: player.name, action: {
                            _ in
                            print("Select winner!")
                            game.selectWinner(player: player, chipGroup: chipGroupIndex)
                            if chipGroupIndex+1 >= game.chipGroups.count {
                                isShowingWinner.toggle()
                            }else {
                                chipGroupIndex += 1
                                isSelectingNextWinner.toggle()
                                
                            }
                        })
                        .disabled(!game.playerIndexCanWinRound(index: chipGroupIndex, player: player))
                        .opacity(game.playerIndexCanWinRound(index: chipGroupIndex, player: player) ? 1 : 0.4)
                    }
                    Spacer()
                }
                .padding(.all)
                .navigationDestination(isPresented: $isShowingWinner, destination: {
                    RoundSummaryView(game: game)
                })
                .navigationDestination(isPresented: $isSelectingNextWinner, destination: {
                    SelectWinnerView(game: game, chipGroupIndex: chipGroupIndex)
                })
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
