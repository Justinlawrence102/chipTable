//
//  ConfigureView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/8/24.
//

import SwiftUI

#if os(tvOS)
struct ConfigureView: View {
    @Namespace private var namespace
    
    @ObservedObject var game = Game()
    
    @State var editMode: EditMode = .active
    @State var defaultFocus = true
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    Form{
                        Section(header: Text("Profile")) {
                            HStack {
                                Text("Starting Chip Count")
                                Spacer()
                                TextField("0", text: $game.name, prompt: Text("0"))
                                    .keyboardType(.numberPad)
                                    .prefersDefaultFocus(true, in: namespace)
                            }
                            Toggle(isOn: $game.requireBigLittle) {
                                Text("Require big and little blind")
                            }
                            Toggle(isOn: $game.increaseMaxBet) {
                                Text("Increase blinds once someone gets out")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                VStack {
                    HStack {
                        Text("PLAYERS")
                            .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                        Spacer()
                    }
                    List($game.players, editActions: .move) {
                        $player in
                        HStack{
                            Circle()
                                .foregroundColor(player.color)
                                .frame(width: 35, height: 35)
                            Text(player.name)
                            Spacer()
                        }
                    }
                    .prefersDefaultFocus(false, in: namespace)
                    .environment(\.editMode, $editMode)
                }
//                .frame(maxWidth: .infinity)
            }
            .focusScope(namespace)
            NavigationLink(destination: {
                GameTableView(game: game)
                    .navigationBarBackButtonHidden(true)
            }, label: {
                buttonView(title: "Confirm and Start")
            })
            .buttonStyle(.card)
            .disabled(game.players.isEmpty)
        }
    }
}
#endif

#Preview {
    ConfigureView()
}
