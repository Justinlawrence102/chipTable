//
//  ConfigureView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

struct ConfigureView: View {
    @ObservedObject var game = Game()
    @State private var isStartingGame = false

    @State var editMode: EditMode = .active
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Setup")
                    .font(Font.system(size: 50, weight: .bold))
                    .foregroundColor(Color("Blue"))
                Spacer()
                TextField( "Enter Game Name",text: $game.name)
                    .padding(.all)
                    .foregroundColor(Color("Blue"))
                    .font(Font.system(size: 18))
                    .frame(width: 400, height: 50)
                    .background(Color("Card"))
                    .cornerRadius(12)
            }
            HStack(spacing: 12.0){
                VStack {
                    HStack {
                        Text("Waiting for players")
                            .font(Font.system(size: 30, weight: .semibold))
                        .foregroundColor(Color("Red"))
                        Spacer()
                    }
                    List($game.players, editActions: .move) {
                        $player in
                        HStack{
                            Circle()
                                .foregroundColor(player.color)
                                .frame(width: 35, height: 35)
                            Text(player.name)
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Blue"))
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                    .environment(\.editMode, $editMode)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(16)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                VStack {
                    HStack {
                        Text("Rules")
                            .font(Font.system(size: 30, weight: .semibold))
                        .foregroundColor(Color("Red"))
                        Spacer()
                    }
                    VStack(spacing: 15.0) {
                        HStack{
                            Text("Starting Chip Count")
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Blue"))
                            Spacer()
                            TextField( "0",text: $game.startingChipCount)
                                .padding(.all)
                                .keyboardType(.numberPad)
                                .foregroundColor(Color("Light Blue"))
                                .font(Font.system(size: 25, weight: .semibold))
                                .frame(width: 80, height: 60)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(12)
                        }
                        HStack{
                            Text("Require big and little bet")
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Blue"))
                            Spacer()
                            Toggle("", isOn: $game.requireBigLittle)
                                .toggleStyle(SwitchToggleStyle(tint: Color("Light Blue")))
                        }
                        HStack{
                            Text("Increase max bet once someone gets out")
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Blue"))
                            Spacer()
                            Toggle("", isOn: $game.requireBigLittle)
                                .toggleStyle(SwitchToggleStyle(tint: Color("Light Blue")))
                        }
                    }
                    .padding(.all)
                    .background(Color("Card"))
                    .cornerRadius(16)
                    Spacer()
                    Button(action: {
                        print("Confirm and Start")
                        isStartingGame.toggle()
                        game.setUpGame()
                    }) {
                        buttonView(title: "Confirm and Start")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $isStartingGame) {
            GameTableView(game: game)
        }
        .padding([.top, .leading, .trailing], 24.0)
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}