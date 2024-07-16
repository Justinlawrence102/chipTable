//
//  TablePositionSelectionView.swift
//  chipTable
//
//  Created by Justin Lawrence on 7/11/24.
//

import SwiftUI

struct TablePositionSelectionView: View {
    @EnvironmentObject var game: Game
    @State var isStartingGame = false
    var body: some View {
        ZStack {
            VStack {
                if game.players.indices.contains(game.currentPlayerIndex) {
                    Text(game.players[game.currentPlayerIndex].name)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("Blue"))
                }
                Text("Tap your location around the table")
                    .font(.title2)
                    .foregroundStyle(Color("Light Blue"))
            }
            .padding(40)
            .background(Color("Card"))
            .cornerRadius(12)
            
            VStack(spacing: 24) {
                HStack(spacing: 24) {
                    SquareTappableView(sort: 0, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 1, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 2, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 3, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 4, isStartingGame: $isStartingGame)
                }
                HStack(spacing: 24) {
                    SquareTappableView( sort: 16, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                    Spacer()
                    SquareTappableView( sort: 6, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                }
                HStack(spacing: 24) {
                    SquareTappableView( sort: 15, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                    Spacer()
                    SquareTappableView( sort: 7, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                }
                HStack(spacing: 24) {
                    SquareTappableView( sort: 14, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                    Spacer()
                    SquareTappableView( sort: 8, isStartingGame: $isStartingGame)
                        .frame(width: 250)
                }
                HStack(spacing: 24) {
                    SquareTappableView( sort: 13, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 12, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 11, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 10, isStartingGame: $isStartingGame)
                    SquareTappableView( sort: 9, isStartingGame: $isStartingGame)
                }
            }
            .padding(24)
            
            ForEach(game.players) {
                player in
                if let point = player.pointPosition {
                    if [0,1,2,3,4,8,9,10,11,12].contains(player.sortPosition ?? 0) {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(
                                .ellipticalGradient(
                                    colors: [player.color, player.color.opacity(0)]))
                            .frame(width: 350, height: 500)
                            .position(point)
                    }else {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(
                                .ellipticalGradient(
                                    colors: [player.color, player.color.opacity(0)]))
                            .frame(width: 500, height: 350)
                            .position(point)
                    }
                }
            }
        }
        .onAppear {
            game.sendSetTablePotionData()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Blue"))
        .fullScreenCover(isPresented: $isStartingGame) {
            GameTableView()
        }
    }
}

#Preview {
    TablePositionSelectionView()
        .environmentObject(Game(withSampleData: true))
}

private struct SquareTappableView: View {
    let squareColor = Color(red: 0.243, green: 0.2901, blue: 0.345)
    let sort: Int
    @EnvironmentObject var game: Game
    @Binding var isStartingGame: Bool
    
    var body: some View {
        squareColor
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .onTapGesture(coordinateSpace: .global) { location in
                print("\(location)")
                game.players[game.currentPlayerIndex].pointPosition = location
                game.players[game.currentPlayerIndex].sortPosition = sort
                game.currentPlayerIndex += 1
                if game.currentPlayerIndex < game.players.count {
                    game.sendSetTablePotionData()
                }else {
                    isStartingGame = true
                    game.setUpGame()
                }
            }
        
    }
}
