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
    @EnvironmentObject var gameManager: PlayerGame
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Setup")
                .font(.title2.weight(.semibold))
            .foregroundColor(Color("Text"))
            #if os(visionOS)
            TextField( "Name",text: $player.name)
                .padding(.all)
                .foregroundColor(Color("Text"))
                .font(Font.system(size: 18))
                .frame(height: 50)
                .background(.ultraThickMaterial)
                .cornerRadius(12)
                .padding(.bottom, 24.0)
            #elseif !os(tvOS)
            TextField( "Name",text: $player.name)
                .padding(.all)
                .foregroundColor(Color("Text"))
                .font(Font.system(size: 18))
                .frame(height: 50)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.bottom, 24.0)
            #endif
            HStack {
                Text("Chip Color")
                    .font(Font.system(size: 22, weight: .semibold))
                .foregroundColor(Color("Text"))
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: 25.0) {
                    ForEach(player.getColorOptions(), id: \.self) { color in
#if os(visionOS)
                        Button(action: {
                            player.color = color
                            print("Selected Color")
                        }) {
                            ZStack {
                                if color == player.color {
                                    Circle()
                                        .strokeBorder(.ultraThinMaterial, lineWidth: 12)
                                        .frame(width: 60, height: 60)
                                }else {
                                    Spacer()
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        .frame(width: 60, height: 60)
                        .background(color)
                        .cornerRadius(30)
                        
#else
                        Button(action: {
                            player.color = color
                            print("Selected Color")
                        }) {
                            ZStack {
                                if color == player.color {
                                    Circle()
                                        .strokeBorder(Color("Light Blue"), lineWidth: 5)
                                }
                                Circle()
                                    .frame(width: 60, height: 60)
                            }
                            .foregroundColor(color)
                            .frame(width: 75, height: 75)
                        }
                        .padding(.trailing, -20)
#endif
                    }
                }
            }
            Spacer()
            PrimaryButtonView(title: "Find Game", action: {
                _ in
                gameManager.addPlayer(player: player)
                isFindingGame.toggle()
            })
                .disabled(player.name == "")
                .opacity(player.name == "" ? 0.5 : 1)

        }
        .overlay(alignment: .topTrailing) {
            xButton(dismiss: _dismiss)
        }
        .safeAreaPadding(.all)
        .fullScreenCover(isPresented: $isFindingGame) {
                FindGameView()
        }
    }
}

struct CircleButton: ButtonStyle {
    var color = Color("Card")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(color)
            .frame(width: 75, height: 75)
    }
}

struct PlayerCreateView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCreateView()
    }
}
