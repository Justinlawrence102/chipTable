//
//  TableView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI

struct GameTableView: View {
    @ObservedObject var game: Game
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
                Button(action: {
                    game.showingWinnerSelectModal.toggle()
                }) {
                    buttonView(title: "Round Over")
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        game.sendData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("Card"))
                            .background(Color("Light Blue"))
                            .cornerRadius(30)
                    }
                    .padding([.bottom, .trailing])
                }
            }
        }
        .background(Color("Blue"))
        .sheet(isPresented: $game.showingWinnerSelectModal) {
                    SelectWinnerView(game: game)
                }
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        GameTableView(game: Game())
            .previewInterfaceOrientation(.landscapeRight)
    }
}

struct CardSpaceView: View {
    @ObservedObject var game: Game
    var body: some View {
        ForEach(game.chips) {
            chip in
            ChipView(color: chip.color)
                .position(x: CGFloat(chip.x), y: CGFloat(chip.y))
        }
    }
}

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
        HStack() {
            if (game.isDealer(player: player)) {
                Image(systemName: "menucard.fill")
                    .foregroundColor(Color("Light Blue"))
                    .font(Font.system(size: 25))
            }else {
                Spacer()
                    .frame(width: 40)
            }
            Text(player.name)
                .foregroundColor(Color("Blue"))
                .font(Font.system(size: 20, weight:player.isMyTurn ? .bold : .medium))
            Spacer()
            if player.folded {
                Text("Fold")
                    .foregroundColor(Color("Light Red"))
                    .font(Font.system(size: 20, weight: .bold))
            } else {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(player.color)
            }
            Text(String(player.currentBet))
                .foregroundColor(Color("Red"))
                .font(Font.system(size: 20, weight: .bold))
                .frame(width: 35)
        }
    }
}
