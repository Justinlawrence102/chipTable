//
//  TutorialView1.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/8/24.
//

import SwiftUI

struct TutorialView1: View {
    @Binding var selectedTabView: Int
    
    @State var ipadOffset = CGFloat(0)
    @State var tvOffset = CGFloat(100)
    @State var visionOffset = CGFloat(100)
    @State var ipadOpactity = Double(1)
    @State var tvOpactity = Double(0)
    @State var visionOpactity = Double(0)
    @State var deviceName = "iPad"
    @State var runningAnimation = true
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Use your ")
                    Text(deviceName)
                }
                Text(" as a Chip Table")
            }
            .font(.title.weight(.semibold))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color("Red"))
            Spacer()
            ZStack {
                Image(systemName: "ipad.landscape")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 120))
                    .offset(x: ipadOffset)
                    .opacity(ipadOpactity)
                
                Image(systemName: "tv")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 120))
                    .offset(x: tvOffset)
                    .opacity(tvOpactity)
                Image(systemName: "visionpro")
                    .foregroundStyle(Color("Light Red"))
                    .font(Font.system(size: 120))
                    .offset(x: visionOffset)
                    .opacity(visionOpactity)
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
            SecondaryButtonView(title: "Continue", action: {
                _ in
                withAnimation {
                    selectedTabView = 2
                }
            })
        }
        .task(firstPageAnimations)
        .onAppear(){
            runningAnimation = true
        }
        .onDisappear(){
            runningAnimation = false
        }
        
        //        .onAppear() {
        //            try? await Task.sleep(12000)
        //        }
        .padding()
    }
    private func firstPageAnimations() async {
        if runningAnimation {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(){
                deviceName = "Apple TV"
                ipadOffset = -100
                ipadOpactity = 0
                tvOffset = 0
                tvOpactity = 1
                visionOffset = 100
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(){
                deviceName = "Apple Vision Pro"
                tvOffset = -100
                tvOpactity = 0
                visionOffset = 0
                visionOpactity = 1
                ipadOffset = 100
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(){
                deviceName = "iPad"
                visionOffset = -100
                visionOpactity = 0
                ipadOffset = 0
                ipadOpactity = 1
                tvOffset = 100
            }
            await firstPageAnimations()
        }
    }
}

struct Turorial1_Previews: PreviewProvider {
  @State static var isShowing = 1
  static var previews: some View {
      TutorialView1(selectedTabView: $isShowing)
  }
}
