//
//  PlayerHandWaitingView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI
#if os(visionOS)
struct PlayerHandWaitingView: View {
    @EnvironmentObject var playerGame: PlayerGame
    
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
            
            VStack(spacing: 8.0){
                Text("Current Wager")
                    .font(.largeTitle.weight(.semibold))
                Text(String(playerGame.currentBetOnTable))
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Red"))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text("Waiting for \(playerGame.currentPlayer)")
                    .font(.headline)
                ProgressView()
            }
            VStack{
                Spacer()
                Text(String(playerGame.player.chipsRemaining))
                    .font(Font.system(size: 28, weight: .bold))
                    .foregroundColor(Color("Blue"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Light Red"))
                    .cornerRadius(30)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("Blue"), Color("Blue").opacity(0), Color("Blue").opacity(0)]), startPoint: .top, endPoint: .bottom)
        )
        .fullScreenCover(isPresented: $playerGame.isYourTurn) {
            PlayerPlayingView()
        }
        .sheet(isPresented: $playerGame.gameOver) {
            PlayerWonView()
        }
    }
}
#else
struct PlayerHandWaitingView: View {
    @EnvironmentObject var playerGame: PlayerGame
    
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
            
            VStack(spacing: 8){
                Text("Current Wager")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Red"))
                Text(String(playerGame.currentBetOnTable))
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Light Red"))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all)
            VStack {
                Text("Waiting for \(playerGame.currentPlayer)")
                    .font(.headline)
                    .foregroundColor(Color("Light Red"))
                ProgressView()
            }
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
            PlayerPlayingView()
        }
        .sheet(isPresented: $playerGame.gameOver) {
            PlayerWonView()
        }
    }
}
#endif
struct PlayerHandWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHandWaitingView()
            .environmentObject(PlayerGame(player: Player()))
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
