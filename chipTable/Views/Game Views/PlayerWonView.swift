//
//  PlayerWonView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/8/24.
//

import SwiftUI
import ConfettiSwiftUI

struct PlayerWonView: View {
    @State var conffetiCount = 0
    @ObservedObject var playerGame: PlayerGame
    
    var body: some View {
        VStack {
            Text("Game Over")
                .font(.title.weight(.semibold))
                .foregroundStyle(Color("Blue"))
            Spacer()
            Text(playerGame.gameState == .playerWon ? "You Won!" : "\(playerGame.currentPlayer) Won!")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("Light Blue"))
            Spacer()
            bottomCardView()
        }
        .confettiCannon(counter: $conffetiCount, num: 80, colors: [Color("Light Blue"), Color("Red"), Color("Card")],rainHeight: 200, openingAngle: Angle.degrees(0), closingAngle: Angle.degrees(360), radius: 300, repetitions: 1, repetitionInterval: 0.8)
        .onAppear(){
            if playerGame.gameState == .playerWon {
                conffetiCount += 1
            }
        }
    }
}

#Preview {
    PlayerWonView(playerGame: PlayerGame(player: Player()))
}
