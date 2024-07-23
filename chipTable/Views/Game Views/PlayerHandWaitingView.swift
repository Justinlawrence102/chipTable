//
//  PlayerHandWaitingView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI
import AudioToolbox

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
                            ForEach(playerGame.playersChips[i]) {
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
                            ForEach(playerGame.playersChips[i]) {
                                chip in
                                ChipView(color: chip.player.color)
                            }
                            Spacer()
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        .rotationEffect(Angle(degrees: 180))
                    }.id(playerGame.rowCounter)
                }
            }
            
            switch playerGame.gameState {
            case .waitingSetup:
                VStack {
                    Text("Waiting for game to start")
                        .font(.headline)
                        .foregroundColor(Color("Light Red"))
                    ProgressView()
                        .tint(.white)
                }
            case .pickTablePosition:
                PickTablePositionState()
            case.waitingPlayers:
                WaitingForPlayerState()
            case .endOfGame:
                PlayerWonView()
            case .playerWon:
                PlayerWonView()
            case .yourTurn:
                WaitingForPlayerState()
            case .endOfRoundSummary:
                EndOfRoundSummaryState()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Blue"))
        .fullScreenCover(isPresented: $playerGame.isYourTurn) {
            PlayerPlayingView()
        }
//        .sheet(isPresented: $playerGame.gameOver) {
//            PlayerWonView()
//        }
        .onAppear(){
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}
#endif
struct PlayerHandWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHandWaitingView()
            .environmentObject(PlayerGame(gameStatePreviews: .endOfRoundSummary))
            .previewLayout(.fixed(width: 300, height: 600))
    }
}

struct WaitingForPlayerState: View {
    @EnvironmentObject var playerGame: PlayerGame
    var body: some View {
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
                .tint(.white)
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
}

struct PickTablePositionState: View {
    @State private var isAnimating = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 4.0)
            .repeatForever(autoreverses: true)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.up")
                .font(Font(UIFont.systemFont(ofSize: 80)))
                .fontWeight(.semibold)
                .foregroundStyle(Color("Light Blue"))
                .rotationEffect(Angle(degrees: self.isAnimating ? 30 : -30))
                .animation(self.foreverAnimation, value: isAnimating)
            Text("Tap you location around the table")
                .font(.headline)
                .foregroundColor(Color("Light Red"))
        }
        .onAppear(){
            isAnimating = true
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
        }
    }
}

struct EndOfRoundSummaryState: View {
    @EnvironmentObject var playerGame: PlayerGame
    var body: some View {
        VStack {
            Text("End of Round")
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(Color("Red"))
            Text(String(playerGame.roundNumber ?? 0))
                .font(.largeTitle.weight(.semibold))
                .foregroundColor(Color("Light Red"))
            VStack(spacing: 8) {
                HStack {
                    Text("Player")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("Blue"))
                    Spacer()
                    Text("Chips Remaining")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("Blue"))
                }
                ForEach(playerGame.players ?? [], id: \.self) {
                    playerName in
                    HStack {
                        Text(playerName)
                            .foregroundStyle(Color("Blue"))
                        Spacer()
                        Text("\(playerGame.getChipsRemainingForPlayer(player: playerName))")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("Red"))
                    }
                    .opacity(playerGame.getChipsRemainingForPlayer(player: playerName) == 0 ? 0.4 : 1)
                }
            }
            .padding()
            .background(Color("Card"))
            .cornerRadius(12)
            .padding()
            Spacer()
        }
    }
}
