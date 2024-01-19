//
//  ContentView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import SwiftUI
#if os(tvOS)
struct HomeView: View {
    @State private var isJoiningGame = false
    @State private var isRejoiningGame = false
    @State private var showingTutorialSheet = false
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        NavigationStack {
            ZStack {
                HStack(spacing: 24.0) {
                    VStack(alignment: .leading) {
                        Text("Welcome To")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Card"))
                        Text("Chip Table")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Red"))
                        
                    }
                    .padding(.leading)
                    Spacer()
                    VStack {
                        NavigationLink(destination: {
                            ConfigureView()
                        }, label:  {
                            buttonView(title: "Start Game")
                        })
                        .buttonStyle(.card)
                        NavigationLink(destination: {
                            TutorialTabView(selectedTabView: 0, showingTutorial: $showingTutorialSheet)
                        }, label:  {
                            buttonView(title: "Learn More", backgroundColor: Color("Card"), titleColor: Color("Light Blue"))
                        })
                        .buttonStyle(.card)
                    }
                    .padding(.trailing)
                }
                Spacer()
                VStack {
                    Spacer()
                    bottomCardView()
                }
            }
            .padding([.leading, .bottom, .trailing], 24.0)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color("Blue").opacity(0.1), Color("Blue")]), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

#else
struct HomeView: View {
    @State private var isJoiningGame = false
    @State private var isRejoiningGame = false
    @State private var showingTutorialSheet = false
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24.0) {
                if idiom == .pad {
                    HStack {
                        Text("Welcome To")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Blue"))
                        Text("Chip Table")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Red"))
                        Spacer()
                    }
                } else {
                    VStack {
                        Text("Welcome To")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Blue"))
                        Text("Chip Table")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(Color("Red"))
                        
                    }
                }
                if idiom == .pad {
                    NavigationLink(destination: {
                        ConfigureView()
                    }, label:  {
                        Text("Start Game")
                    })
                    .buttonStyle(PrimaryButtonStyle())
                }
                if (idiom == .pad) {
                    SecondaryButtonView(title: "Join Game", action: {
                        _ in
                        isJoiningGame.toggle()
                    })
                }else {
                    PrimaryButtonView(title: "Join Game", action: {
                        _ in
                        isJoiningGame.toggle()
                    })
                }
                
                SecondaryButtonView(title: "Rejoin Game", action: {
                    _ in
                    isRejoiningGame.toggle()
                })
                
                if idiom == .phone {
                    Text("An iPad or Apple TV is required to be the table and start the game")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("Light Red"))
                        .font(Font.system(size: 14, weight: .regular))
                    
                }
                Spacer()
                bottomCardView()
                    .sheet(isPresented: $isJoiningGame, content: PlayerCreateView.init)
                    .sheet(isPresented: $isRejoiningGame) {
                        RejoinGameView()
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
                TutorialTabView(selectedTabView: 0, showingTutorial: $showingTutorialSheet)
            }
        }
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}


