//
//  TableView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI
import ConfettiSwiftUI

#if os(tvOS)
struct GameTableView: View {
//    @ObservedObject var game: Game
    @EnvironmentObject var game: Game
    @State var showPickWinnerAlertSheet = false
    @State var chipGroupIndex = 0
    
    var body: some View {
        ZStack {
            //game space
            CardSpaceView(game: game)
                .frame(width: 800, height: 450)
            
            VStack {
                HStack(alignment: .top) {
                    Text("Round \(game.round)")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(Color("Red"))
                    Spacer()
                }
                Spacer()
//                bottomCardView()
                    .padding(.bottom, -60.0)
            }
            .padding(.all)
            if game.bettingRoundOver {
                VStack {
                    Text("Flip over next card(s)")
                        .font(Font.system(size: 24, weight: .semibold))
                        .foregroundColor(Color("Red"))
                        .multilineTextAlignment(.center)
                }
                .padding(.all, 40.0)
                .background(Color("Card"))
                .cornerRadius(12)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    showPickWinnerAlertSheet.toggle()
                }) {
                    buttonView(title: "Round Over")
                }
                .buttonStyle(.card)
                .contextMenu {
                        Button {
                            game.showingWinnerSelectModal.toggle()
                        } label: {
                            Label("Pick Winner", systemImage: "heart")
                        }
                        Button {
                            game.sendData()
                        } label: {
                            Label("Reload", systemImage: "arrow.clockwise")
                        }
                    }
            }
        }

        .overlay(alignment: .topTrailing, content: {
            VStack(spacing: 8.0){
                ForEach(game.players) {
                    player in
                    PlayerScoreView(player: player, game: game)
                }
            }
            .padding(.all)
            .frame(width: 350)
            .background(Color("Card"))
            .cornerRadius(12)
        })
        .overlay(alignment: .bottomLeading, content: {
            ZStack {
                Image(systemName: "suit.diamond.fill")
                    .font(Font.system(size: 90))
                    .foregroundColor(Color("Red"))
                    .frame(width: 250, height: 350)
                    .background(Color("Card"))
                    .cornerRadius(20)
                    .rotationEffect(Angle.degrees(5))
                    .offset(x: 130, y: 0)
                    .shadow(radius: 7)
                Image(systemName: "suit.club.fill")
                    .font(Font.system(size: 90))
                    .foregroundColor(Color("Blue"))
                    .frame(width: 250, height: 350)
                    .background(Color("Card"))
                    .cornerRadius(20)
                    .rotationEffect(Angle.degrees(-6))
                    .shadow(radius: 7)
                Image(systemName: "suit.heart.fill")
                    .font(Font.system(size: 90))
                    .foregroundColor(Color("Red"))
                    .frame(width: 250, height: 350)
                    .background(Color("Card"))
                    .cornerRadius(20)
                    .rotationEffect(Angle.degrees(-18))
                    .offset(x: -120, y: 30)
                    .shadow(radius: 7)
            }
            .offset(y: 40)
        })
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                game.sendData()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 30))
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("Light Blue"))
                    .cornerRadius(30)
            }
        })
//        .overlay(alignment: .bottomTrailing, content: {
//            if let players = game.get2dArrayOfPlayers() {
//                VStack(spacing: -60.0) {
//                    ForEach(players, id:\.self) {
//                        list in
//                        HStack(spacing: 8.0) {
//                            ForEach(list) { player in
//                                VStack(spacing: -25.0) {
//                                    ForEach(0..<(player.chipsRemaining < 30 ? player.chipsRemaining : 30 )) { j in
//                                        ZStack {
//                                            Ellipse()
//                                                .frame(width: 78, height: 40)
//                                                .foregroundColor(.white)
//                                            Image("Chip")
//                                                .resizable()
//                                                .frame(width: 80, height: 40)
//                                                .foregroundColor(player.color)
//                                                .shadow(radius: 7)
//                                        }
//                                    }
//                                }
//                                .rotationEffect(Angle.degrees(180))
//                            }
//                        }
//                    }
//                }
//            }
//        })
        
        .confettiCannon(counter: $game.startConffeti, num: 120, colors: [Color("Light Blue"), Color("Red"), Color("Card")],rainHeight: 200, openingAngle: Angle.degrees(0), closingAngle: Angle.degrees(360), radius: 550, repetitions: 1, repetitionInterval: 0.8)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Blue").opacity(0.1), Color("Blue")]), startPoint: .top, endPoint: .bottom))
        .alert("Select Winner", isPresented: $showPickWinnerAlertSheet) {
            ForEach(game.players) {
                player in
                Button(player.name, action: {
                    game.selectWinner(player: player, chipGroup: chipGroupIndex)
                    
                    if chipGroupIndex+1 >= game.chipGroups.count {
                        game.showingWinnerSelectModal.toggle()
                        chipGroupIndex = 0
                    }else {
                        chipGroupIndex += 1
                        showPickWinnerAlertSheet.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showPickWinnerAlertSheet = true
                        }
                        
                    }
//                    game.selectWinner(player: player)
//                    game.showingWinnerSelectModal.toggle()
                })
                .disabled(!game.playerIndexCanWinRound(index: chipGroupIndex, player: player))
                .opacity(game.playerIndexCanWinRound(index: chipGroupIndex, player: player) ? 1 : 0.4)
            }
            Button("Cancel", role: .cancel, action: {})
        }
        .sheet(isPresented: $game.showingWinnerSelectModal) {
            RoundSummaryView(game: game)
        }
    }
}
#elseif os(visionOS)
struct GameTableView: View {
    @EnvironmentObject var gameManager: PlayerGame
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            CardSpaceView(game: gameManager)
                .frame(width: 800, height: 400)
            VStack {
                HStack(alignment: .top) {
                    Text("Round \(gameManager.roundNumber ?? 1)")
                        .font(.extraLargeTitle)
                        .foregroundColor(Color("Red"))
                    Spacer()
                }
                Spacer()
                bottomCardView()
                    .padding(.bottom, -60.0)
            }
            .padding(.all)
            .overlay(alignment: .topTrailing){
                VStack {
                    ForEach(gameManager.players ?? [], id: \.self) {
                        playerName in
                        HStack {
                            Text(playerName)
                            Spacer()
                            Text(gameManager.getChipsForPlayer(player: playerName))
                                .font(.title.weight(.semibold))
                        }
                        .fontWeight(playerName == gameManager.currentPlayer ? .bold : .regular)
                    }
                }
                .frame(width: 200)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(25)
                .padding(24)
            }
            .overlay(alignment: .bottom){
                SecondaryButtonView(title: "Exit Game", action: {
                    _ in
                    dismissWindow(id: "GameTable")
                    dismiss()
                })
                .padding()
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("Blue").opacity(0), Color("Blue").opacity(0.4), Color("Blue")]), startPoint: .top, endPoint: .bottom)
            )
//        .background(Color("Blue"))
    }
}
#else
struct GameTableView: View {
    @EnvironmentObject var game: Game
    @State var showingConfigureView = false
    
    var body: some View {
        ZStack {
            //game space
            CardSpaceView(game: game)
                .frame(width: 800, height: 400)
//                .background(.red)
            
            VStack {
                HStack(alignment: .top) {
                    Text("Round \(game.round)")
                        .font(Font.system(size: 50, weight: .bold))
                        .foregroundColor(Color("Red"))
                    Spacer()
                    VStack(spacing: 8.0){
                        ForEach(game.players) {
                            player in
                            PlayerScoreView(player: player, game: game)
                        }
                    }
                    .padding(.all)
                    .frame(width: 300)
                    .background(Color("Card"))
                    .cornerRadius(12)
                }
                Spacer()
                bottomCardView()
                    .padding(.bottom, -60.0)
            }
            .padding(.all)
            if game.bettingRoundOver {
                VStack {
                    Text("Flip over next card(s)")
                        .font(Font.system(size: 24, weight: .semibold))
                        .foregroundColor(Color("Red"))
                        .multilineTextAlignment(.center)
                }
                .padding(.all, 40.0)
                .background(Color("Card"))
                .cornerRadius(12)
            }
            
            VStack {
                Spacer()
                PrimaryButtonView(title: "Round Over", action: {
                    _ in
                    game.showingWinnerSelectModal.toggle()
                })
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingConfigureView.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("Card"))
                            .background(Color("Light Blue"))
                            .cornerRadius(30)
                    }
                    .padding([.bottom, .trailing])
                }
            }
        }
        .confettiCannon(counter: $game.startConffeti, num: 120, colors: [Color("Light Blue"), Color("Red"), Color("Card")],rainHeight: 200, openingAngle: Angle.degrees(0), closingAngle: Angle.degrees(360), radius: 550, repetitions: 1, repetitionInterval: 0.8)
        .background(Color("Blue"))
        .sheet(isPresented: $game.showingWinnerSelectModal) {
            SelectWinnerView(game: game)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingConfigureView, content: {
            ManageGameView()
        })
        .onAppear() {
            game.setUpGame()
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#endif
struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(visionOS)
        GameTableView()
            .environmentObject(PlayerGame(player: Player()))
        #else
        GameTableView()
            .environmentObject(Game(withSampleData: true))
            .previewInterfaceOrientation(.landscapeRight)
        #endif
    }
}

#if os(visionOS)
struct CardSpaceView: View {
    @ObservedObject var game: PlayerGame
    var body: some View {
        ForEach(game.chipsOnTableDecoded, id: \.self) {
            chip in
            ChipView(color: chip.color)
                .position(x: CGFloat(chip.x), y: CGFloat(chip.y))
        }
    }
}
#else
struct CardSpaceView: View {
    @ObservedObject var game: Game
    var body: some View {
        HStack {
            ForEach(game.chipGroups) {
                chipGroup in
                ZStack {
                    CardSpaceGroupView(chipGroups: chipGroup)
                }
                .frame(width: 700/CGFloat(game.chipGroups.count), height: 300)
            }
        }
    }
}

struct CardSpaceGroupView: View {
    @ObservedObject var chipGroups: ChipGroup
    var body: some View {
        ForEach(chipGroups.chips) {
            chip in
            ChipView(color: chip.player.color)
                .position(x: CGFloat(chip.x), y: CGFloat(chip.y))
                .transition(.offset(x: chip.xOffset, y: chip.yOffset).combined(with: .opacity))
        }
    }
}
#endif

struct ChipView: View {
    var color: Color
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 88, height: 88)
                .foregroundColor(.white)
            Image("Chip")
                .resizable()
                .frame(width: 90, height: 90)
                .foregroundColor(color)
                .shadow(radius: 7)
        }
        
    }
}


struct PlayerScoreView: View {
    @ObservedObject var player: Player
    var game: Game
    var body: some View {
        HStack(spacing: 8.0) {
            if (game.isDealer(player: player)) {
                Image(systemName: "menucard.fill")
                    .foregroundColor(Color("Light Blue"))
                    .font(Font.system(size: 25))
            }else {
                Spacer()
                    .frame(width: 35)
            }
            Text(player.name)
                .foregroundColor(Color("Blue"))
                .font(.body.weight(player.isMyTurn ? .bold : .medium))
            Spacer()
            if player.folded {
                Text("Fold")
                    .foregroundColor(Color("Light Red"))
                    .font(.body.weight(.bold))
            } else {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(player.color)
            }
            Text(String(player.currentBet))
                .foregroundColor(Color("Red"))
                .font(.body.weight(.bold))
                .frame(width: 35)
        }
        .opacity(player.chipsRemaining == 0 ? 0.4 : 1)
    }
}
