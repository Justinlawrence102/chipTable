//
//  ContentView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI
struct HomeView: View {
    @State private var isStartingGame = false
    @State private var isJoiningGame = false
    @State private var isRejoiningGame = false
    @State private var showingTutorialSheet = false
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        NavigationView {
            VStack(spacing: 24.0) {
                if idiom == .pad {
                    HStack {
                        Text("Welcome To")
                            .font(Font.system(size: 50, weight: .bold))
                            .foregroundColor(Color("Blue"))
                        Text("Chip Table")
                            .foregroundColor(Color("Red"))
                            .font(Font.system(size: 50, weight: .bold))
                        Spacer()
                    }
                } else {
                    VStack {
                        Text("Welcome To")
                            .font(Font.system(size: 50, weight: .bold))
                            .foregroundColor(Color("Blue"))
                        Text("Chip Table")
                            .foregroundColor(Color("Red"))
                            .font(Font.system(size: 50, weight: .bold))
                    }
                }
                if idiom == .pad {
                    Button(action: {
                        isStartingGame.toggle()
                        print("Start Game")
                    }) {
                        buttonView(title: "Start Game")
                    }
                }
                Button(action: {
                    print("Join Game")
                    isJoiningGame.toggle()
                }) {
                    buttonView(title: "Join Game", backgroundColor: Color(idiom == .pad ? "Card" : "Light Blue"), titleColor: Color(idiom == .pad ? "Light Blue" : "Card"))
                }
                Button(action: {
                    print("Join Game")
                    isRejoiningGame.toggle()
                }) {
                    buttonView(title: "Rejoin Exisiting Game", backgroundColor: Color("Card"), titleColor: Color( "Light Blue"))
                }
                if idiom == .phone {
                    Text("An iPad is required to act as the table and start the game")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("Light Red"))
                        .font(Font.system(size: 14, weight: .regular))
                    
                }
                Spacer()
                bottomCardView()
                    .fullScreenCover(isPresented: $isStartingGame, content: ConfigureView.init)
                    .sheet(isPresented: $isJoiningGame, content: PlayerCreateView.init)
                    .sheet(isPresented: $isRejoiningGame) {
                        RejoinGameView(gameManager: PlayerGame(player: Player()))
                    }
            }
            .toolbar {
                Button(action: {
                    showingTutorialSheet.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(Color("Light Blue"))
                })
                
            }
            .padding([.leading, .bottom, .trailing], 24.0)
            .sheet(isPresented: $showingTutorialSheet) {
                TutorialView1(selectedTabView: 0, showingTutorial: $showingTutorialSheet)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
