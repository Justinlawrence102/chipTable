//
//  TutorialView2.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/15/24.
//

import SwiftUI

struct TutorialView2: View {
    @Binding var selectedTabView: Int
    @State var startAnimation = false
    var body: some View {
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
                    .offset(CGSize(width: 0, height: startAnimation ? -30 : 30))
                    .animation(
                        Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                        value: startAnimation
                    )
                Image(systemName: "iphone.gen1")
                    .foregroundStyle(Color("Light Blue"))
                    .font(Font.system(size: 150))
                    .padding(.top, 32)
                    .offset(CGSize(width: 0, height: startAnimation ? 0 : 40))
                    .animation(
                        Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                        value: startAnimation
                    )
            }
            HStack {
                Image(systemName: "iphone")
                    .foregroundStyle(Color("Light Blue"))
                    .font(Font.system(size: 150))
                    .offset(CGSize(width: 0, height: startAnimation ? 40 : -40))
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: startAnimation
                    )
                Image(systemName: "ipad")
                    .foregroundStyle(Color("Light Blue"))
                    .font(Font.system(size: 150))
                    .padding(.trailing, 33)
                    .padding(.top, 40)
                    .offset(CGSize(width: 0, height: startAnimation ? -30 : 20))
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: startAnimation
                    )
            }
            Spacer()
            SecondaryButtonView(title: "Continue", action: {
                _ in
                withAnimation {
                    selectedTabView = 3
                }
            })
        }
        .padding()
        .onAppear {
            startAnimation.toggle()
        }
    }
}

struct Turorial2_Previews: PreviewProvider {
  @State static var isShowing = 1
  static var previews: some View {
      TutorialView2(selectedTabView: $isShowing)
  }
}
