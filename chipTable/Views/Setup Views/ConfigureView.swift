//
//  ConfigureView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI

#if os(tvOS)
struct ConfigureView: View {
    @Namespace private var namespace
    
    @ObservedObject var game = Game()
    
    @State var editMode: EditMode = .active
    @State var defaultFocus = true
    @State var isStartingGame = false
    
    var body: some View {
        VStack(spacing: 12.0) {
            Text("Configure Game")
                .font(.largeTitle.weight(.semibold))
            HStack {
                VStack(spacing: 8) {
                    HStack {
                        Text("SETTINGS")
                            .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                        Spacer()
                    }
                    HStack {
                        Text("Starting Chip Count")
                        Spacer()
                        TextField("0", text: $game.startingChipCount, prompt: Text("0"))
                            .keyboardType(.numberPad)
                            .prefersDefaultFocus(true, in: namespace)
                    }
                    Toggle(isOn: $game.requireBigLittle) {
                        Text("Require big and little blind")
                    }
                    Toggle(isOn: $game.increaseMaxBet) {
                        Text("Increase blinds once someone gets out")
                    }
                    Spacer()
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
                    if (game.players.isEmpty) {
                        VStack {
                            Text("Waiting for players")
                                .font(.title3.weight(.medium))
                            .foregroundColor(Color("Red"))
                            ProgressView()
                            Spacer()
                        }
                    }else {
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
                }
            }
            .focusScope(namespace)
            Button(action: {
                print("Confirm and Start")
                isStartingGame.toggle()
                game.setUpGame()
            }) {
                buttonView(title: "Confirm and Start")
            }
            .buttonStyle(.card)
            .disabled(game.players.isEmpty)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("Blue").opacity(0.1), Color("Blue")]), startPoint: .top, endPoint: .bottom)
        )
        .sheet(isPresented: $isStartingGame) {
            GameTableView()
                .environmentObject(game)
        }
    }
}
#else
struct ConfigureView: View {
    @ObservedObject var game = Game()

    @State var editMode: EditMode = .active
    @State var isStartingGame = false
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Setup")
                    .font(Font.system(size: 50, weight: .bold))
                    .foregroundColor(Color("Blue"))
                Spacer()
//                TextField( "Enter Game Name",text: $game.name)
//                    .padding(.all)
//                    .foregroundColor(Color("Blue"))
//                    .font(Font.system(size: 18))
//                    .frame(width: 400, height: 50)
//                    .background(Color("Card"))
//                    .cornerRadius(12)
            }
            HStack(spacing: 12.0){
                VStack {
                    HStack {
                        Text("Waiting for players")
                            .font(Font.system(size: 30, weight: .semibold))
                        .foregroundColor(Color("Red"))
                        Spacer()
                    }
                    VStack {
                        ForEach(game.players) {
                            player in
                            HStack{
                                Circle()
                                    .foregroundColor(player.color)
                                    .frame(width: 35, height: 35)
                                Text(player.name)
                                    .font(Font.system(size: 20, weight: .medium))
                                .foregroundColor(Color("Text"))
                                Spacer()
                                Button(action: {
                                    game.startingDealerId = player.id
                                }, label: {
                                    if game.startingDealerId == player.id {
                                        Image(systemName: "menucard.fill")
                                            .font(.title)
                                    }else {
                                        Text("Set Dealer")
                                    }
                                })
                                .foregroundStyle(Color("Light Blue"))
                            }
                            Divider()
                        }
                        Spacer()
                    }
                    .frame(minHeight: 400)
                    .frame(maxWidth: .infinity)
                    .padding(.all)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    Spacer()
//                    List($game.players, editActions: .move) {
//                        $player in
//                        HStack{
//                            Circle()
//                                .foregroundColor(player.color)
//                                .frame(width: 35, height: 35)
//                            Text(player.name)
//                                .font(Font.system(size: 20, weight: .medium))
//                            .foregroundColor(Color("Blue"))
//                            Spacer()
//                        }
//                        .listRowBackground(Color.clear)
//                    }
//                    .environment(\.editMode, $editMode)
//                    .frame(maxHeight: .infinity)
//                    .cornerRadius(16)
                }
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
                            .foregroundColor(Color("Text"))
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
                            Text("Require big and little blind")
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Text"))
                            Spacer()
                            Toggle("", isOn: $game.requireBigLittle)
                                .toggleStyle(SwitchToggleStyle(tint: Color("Light Blue")))
                        }
                        HStack{
                            Text("Increase blinds once someone gets out")
                                .font(Font.system(size: 20, weight: .medium))
                            .foregroundColor(Color("Text"))
                            Spacer()
                            Toggle("", isOn: $game.increaseMaxBet)
                                .toggleStyle(SwitchToggleStyle(tint: Color("Light Blue")))
                        }
                    }
                    .padding(.all)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    Spacer()
                    NavigationLink(destination: {
                        TablePositionSelectionView()
                            .environmentObject(game)
                    }, label:  {
                        buttonView(title: "Set Order")
                    })
                        .disabled(game.players.isEmpty)
//                    PrimaryButtonView(title: "Set Order", action: {
//                        _ in
//                        print("Confirm and Start")
//                        isStartingGame.toggle()
////                        game.setUpGame()
//                    })
//                    .disabled(game.players.isEmpty)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $isStartingGame) {
            #if os(visionOS)
            GameTableView()
            #else
//            GameTableView(game: game)
            #endif
        }
        .padding([.top, .leading, .trailing], 24.0)
    }
}
#endif

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
