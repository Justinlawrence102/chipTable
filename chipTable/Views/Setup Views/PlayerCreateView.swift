//
//  PlayerCreateView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

struct PlayerCreateView: View {
    @ObservedObject var player = Player()
    @State private var isFindingGame = false
    
    var body: some View {
        VStack {
            Text("Setup")
                .font(Font.system(size: 24, weight: .semibold))
            .foregroundColor(Color("Blue"))
            TextField( "Name",text: $player.name)
                .padding(.all)
                .foregroundColor(Color("Red"))
                .font(Font.system(size: 18))
                .frame(height: 50)
                .background(Color("Card"))
                .cornerRadius(12)
                .padding(.bottom, 24.0)
            
            HStack {
                Text("Chip Color")
                    .font(Font.system(size: 22, weight: .semibold))
                .foregroundColor(Color("Red"))
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 25.0) {
                    ForEach(player.getColorOptions(), id: \.self) { color in
                        
                        Button(action: {
                            player.color = color
                            print("Selected Color")
                        }) {
                            ZStack {
                                if color == player.color {
                                    Circle()
                                        .strokeBorder(Color("Light Blue"), lineWidth: 5)
                                        .frame(width: 75, height: 75)
                                }
                                Circle()
                                    .foregroundColor(color)
                                .frame(width: 60, height: 60)
                            }
                        }
                    }
                }
            }
            Spacer()
            Button(action: {
                isFindingGame.toggle()
                print("Find Game")
            }) {
                Text("Find Game")
            }
            .buttonStyle(PrimaryButton())
            .disabled(player.name == "")
        }
        .padding(.all)
        .fullScreenCover(isPresented: $isFindingGame) {
                FindGameView(gameManager: PlayerGame(player: player))
        }
    }
}

struct PlayerCreateView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCreateView()
    }
}
