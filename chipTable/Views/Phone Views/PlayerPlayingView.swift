//
//  PlayerPlayingView.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/6/23.
//

import SwiftUI
import AudioToolbox

#if os(visionOS)
struct PlayerPlayingView: View {
    @EnvironmentObject var playerGame: PlayerGame
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("Current Wager")
                    .font(.largeTitle.weight(.semibold))
                Text(String(playerGame.currentBetOnTable))
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Red"))
                
                PlayerChipCountView(player: playerGame.player)
                PrimaryButtonView(title: "Match", action: {
                    _ in
                    playerGame.matchBet()
                })
                PrimaryButtonView(title: "Raise + 1", action: {
                    _ in
                    print("Raise 1")
                    playerGame.raise1()
                })
                Spacer()
                PrimaryButtonView(title: "Send Chips", action: {
                    _ in
                    print("Send Chips")
                    playerGame.sendChips()
                })
                
                SecondaryButtonView(title: "Fold", action: {
                    _ in
                    playerGame.fold()
                    print("Fold")
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 40.0)
            .padding(.vertical)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color("Blue"), Color("Blue").opacity(0), Color("Blue").opacity(0)]), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}
#else
struct PlayerPlayingView: View {
    @EnvironmentObject var playerGame: PlayerGame
    @State var goAllInAlertIsPresented = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("Current Wager")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Red"))
                Text(String(playerGame.currentBetOnTable))
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(Color("Light Red"))
                
                PlayerChipCountView(player: playerGame.player)
                PrimaryButtonView(title: "Match", action: {
                    _ in
                    playerGame.matchBet()
                })
                PrimaryButtonView(title: "Raise + 1", action: {
                    _ in
                    print("Raise 1")
                    playerGame.raise1()
                })
                Spacer()
                PrimaryButtonView(title: "Send Chips", action: {
                    _ in
                    print("Send Chips")
                    playerGame.sendChips()
                })
                
                SecondaryButtonView(title: "Fold", action: {
                    _ in
                    playerGame.fold()
                    print("Fold")
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .background(Color("Blue"))
        .onShake {
#if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
#endif
            goAllInAlertIsPresented.toggle()
        }
        .alert("Go All In?", isPresented: $goAllInAlertIsPresented){
            Button(role: .cancel, action: { }, label: {
                Text("Cancel")
            })
            Button(role: .none, action: {
                playerGame.goAllIn()
            }, label: {
                Text("All In!")
            })
        }message: {
            Text("Would you like to bet all of your remaining chips?")
        }
        .onAppear(){
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
        }
    }
}
#endif
struct PlayerChipCountView: View {
    @ObservedObject var player: Player
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(player.chipsRemaining))
                    .font(.title.weight(.bold))
                    .foregroundColor(Color("Red"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Card"))
                    .cornerRadius(12)
                Text("Chips Remaining")
                    .font(Font.system(size: 18, weight: .regular))
                    .foregroundColor(Color("Light Red"))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text(String(player.currentBet))
                    .font(.title.weight(.bold))
                    .foregroundColor(Color("Red"))
                    .padding()
                    .frame(width: 90, height: 90)
                    .background(Color("Card"))
                    .cornerRadius(12)
                Text("My Wager")
                    .font(Font.system(size: 18, weight: .regular))
                    .foregroundColor(Color("Light Red"))
            }
        }
        .padding(.top)
    }
}

struct PlayerPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPlayingView()
            .environmentObject(PlayerGame(player: Player()))
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
