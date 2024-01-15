//
//  TutorialView1.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/8/24.
//

import SwiftUI

struct TutorialTabView: View {
    @State var selectedTabView: Int
    @Binding var showingTutorial: Bool

    var body: some View {
        TabView(selection: $selectedTabView) {
            TutorialView1(selectedTabView: $selectedTabView)
            .tag(1)
            TutorialView2(selectedTabView: $selectedTabView)
            .tag(2)
            TutorialView3(showingTutorial: $showingTutorial)
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(Color("Blue"))
    }
}
func firstPageAnimation() {
    
}

struct AddContainer_Previews: PreviewProvider {
  @State static var isShowing = false
  static var previews: some View {
      TutorialTabView(selectedTabView: 1, showingTutorial: $isShowing)
  }
}
