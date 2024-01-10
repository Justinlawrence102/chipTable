//
//  TutorialView1.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/8/24.
//

import SwiftUI

struct TutorialView1: View {
    @State var selectedTabView: Int
    @Binding var showingTutorial: Bool
    var body: some View {
        TabView(selection: $selectedTabView) {
            VStack {
                Text("Use an iPad as your Chip Table")
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("Red"))
                Spacer()
                HStack {
                    Image(systemName: "ipad.landscape")
                        .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 120))
                    
                    Image(systemName: "tv")
                        .foregroundStyle(Color("Light Red"))
                        .font(Font.system(size: 120))
                }
                HStack {
                    Image(systemName: "iphone")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 100))
                    Image(systemName: "iphone")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 100))
                    Image(systemName: "iphone")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 100))
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedTabView = 2
                    }
                }, label: {
                    Text("Continue")
                })
                .buttonStyle(SecondaryButton())
            }
            .tag(1)
            .padding()
            VStack {
                Text("Connect your iOS devices to join the game")
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("Red"))
                Spacer()
                HStack {
                    Image(systemName: "iphone")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 150))
                        .padding(.trailing, 33)
                        .padding(.top, -55)
                    Image(systemName: "iphone.gen1")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 150))
                        .padding(.top, 32)
                }
                HStack {
                    Image(systemName: "iphone")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 150))
                    Image(systemName: "ipad")
                        .foregroundStyle(Color("Light Blue"))
                        .font(Font.system(size: 150))
                        .padding(.trailing, 33)
                        .padding(.top, -55)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedTabView = 3
                    }
                }, label: {
                    Text("Continue")
                })
                .buttonStyle(SecondaryButton())
            }
            .padding()
            .tag(2)
            VStack {
                Text("Play locally with no Internet required")
                    .font(.title.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("Red"))
                Spacer()
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 250))
                Spacer()
                Button(action: {
                    showingTutorial = false
                }, label: {
                    Text("Get Started")
                })
                .buttonStyle(PrimaryButton())
            }
            .padding()
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(Color("Blue"))
    }
}

struct AddContainer_Previews: PreviewProvider {
  @State static var isShowing = false
  static var previews: some View {
      TutorialView1(selectedTabView: 1, showingTutorial: $isShowing)
  }
}
