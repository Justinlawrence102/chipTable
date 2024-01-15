//
//  TutorialView3.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/15/24.
//

import SwiftUI

struct TutorialView3: View {
    @Binding var showingTutorial: Bool
    @State private var animation = 0
    
    var body: some View {
        VStack {
            Text("Play locally with no Internet required")
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("Red"))
            Spacer()
            if #available(iOS 17.0, *) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 250))
                    .symbolEffect(.bounce.up.byLayer, value: animation)
            }else {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 250))
            }
            Spacer()
            PrimaryButtonView(title: "Get Started", action: {
                _ in
                showingTutorial = false
            })
        }
        .padding()
        .onAppear(){
            animation += 1
        }
    }
}
//
//#Preview {
//    TutorialView3()
//}
