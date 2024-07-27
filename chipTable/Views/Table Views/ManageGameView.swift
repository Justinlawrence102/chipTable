//
//  ManageGameView.swift
//  chipTable
//
//  Created by Justin Lawrence on 7/24/24.
//

import SwiftUI
import MultipeerConnectivity

struct ManageGameView: View {
    @EnvironmentObject var game: Game

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Configure Game")
                    .font(Font.system(size: 30, weight: .semibold))
                    .foregroundColor(Color("Blue"))
                HStack(spacing: 8) {
                    NavigationLink(destination: {
                        List(game.players) {
                            player in
                            PlayerRowView(player: player)
                        }
                    }, label: {
                        VStack(spacing: 12) {
                            Image(systemName: "faxmachine.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color("Light Blue"))
                            Text("Manual Override")
                                .font(.title2)
                                .foregroundStyle(Color("Text"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .padding(24)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    })

                    NavigationLink(destination: {
                        List(game.session.connectedPeers, id: \.self) {
                            peer in
                            if let player = game.players.first(where: {$0.peerId == peer}) {
                                PlayerConnectionDetailsView(peer: peer, player: player)
                            }
                        }
                    }, label: {
                        VStack(spacing: 12) {
                            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                                .font(.system(size: 60))
                                .foregroundStyle(Color("Light Blue"))
                            Text("Connected Devices")
                                .font(.title2)
                                .foregroundStyle(Color("Text"))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .padding(24)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    })

                }
                Spacer()
                PrimaryButtonView(title: "Re-Sync Data", action: {
                    _ in
                    game.sendData()
                })
            }
            .padding()
        }
        .overlay(alignment: .topTrailing, content: {
            xButton()
                .padding()
        })
    }
}

#Preview {
    ManageGameView()
        .environmentObject(Game(withSampleData: true))
}

private struct PlayerRowView: View {
    @ObservedObject var player: Player
    var body: some View {
        HStack {
            Text(player.name)
                .foregroundColor(Color("Text"))
                .font(.body.weight(.medium))
            Spacer()
            Button(action: {
                player.chipsRemaining -= 1
            }, label: {
                Image(systemName: "minus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color("Light Blue"))
                    .font(.title)
            })
            .disabled(player.chipsRemaining == 0)
            Text(String(player.chipsRemaining))
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(player.color)
                .cornerRadius(20)
                .minimumScaleFactor(0.5)
            Button(action: {
                player.chipsRemaining += 1
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color("Light Blue"))
                    .font(.title)
            })
            .buttonStyle(.plain)
        }
    }
}

struct PlayerConnectionDetailsView: View {
    let peer: MCPeerID
    @ObservedObject var player: Player
    @State var showAlert = false
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showAlert.toggle()
                }, label: {
                    Label(player.name, systemImage: "pencil")
                })
                .foregroundColor(Color("Text"))
                .fontWeight(.semibold)
                
                Spacer()
                Menu {
                    ForEach(player.getColorOptions(), id: \.self) { color in
                        Button(action: {
                            player.color = color
                        }) {
                            Text(player.getColorString(color: color))
                        }
                    }
                } label: {
                    Text(player.getColorString())
                        .padding()
                        .background(player.color)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                
            }
            Text("\(peer.displayName) - \(peer.description)")
        }
        .alert("Login", isPresented: $showAlert, actions: {
            TextField("Name", text: $player.name)
            Button("Done", role: .cancel, action: {})
        }, message: {
            Text("Enter new name for player")
        })
    }
}
