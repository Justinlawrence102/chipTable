//
//  GameSpacialView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/10/24.
//

import SwiftUI
//import RealityKit

#if os(visionOS)
struct GameRealityView: View {
    var body: some View {
//        RealityView {_ in 
            Text("Hello?")
//        }
//        ZStack{
//            Rectangle()
//                .background(Color.red)
//                .rotation3DEffect(Angle.degrees(30), axis: (x: 0, y: 00, z: 0))
//                .frame(width: 400, height: 400)
//
//            Text("Hello, World!")
//                .frame(maxWidth: .infinity)
//        }
//            .frame
//            .padding()
//            .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .volumetric, traits: .fixedLayout(width: 600, height: 600, depth: 30)) {
    GameRealityView()
//        .windowStyle(.volumetric)
}

#endif
