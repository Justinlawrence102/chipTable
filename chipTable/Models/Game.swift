//
//  Game.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

class Game: NSObject, ObservableObject {
    @Published var players: [Player]
    @Published var name: String
    var dealerIndex: Int
    var round = 0
    var minBet = 2
    var requireBigLittle = true
    var increaseMaxBet = true
    var startingChipCount = ""
    var currentBetOnTable = 0
    private var currentPlayerIndex: Int
    
    //mulipeer connectivity
    private let serviceType = "chipTable-serv"
    private var myPeerID: MCPeerID
    
    public var serviceAdvertiser: MCNearbyServiceAdvertiser
    public var serviceBrowser: MCNearbyServiceBrowser
    public var session: MCSession
    
    
    override init() {
        
        players = [] //[Player(name: "Justin", color: .red), Player(name: "Mark", color: .green), Player(name: "Allison", color: .yellow)] //, Player(name: "Nicole", color: .purple)
        name = ""
        dealerIndex = 0
        currentPlayerIndex = 0
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        advertiseTableToPlayers()
        
    }
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func getCurrentPlayer()->Player {
        return players[currentPlayerIndex]
    }
    
    func isPlayingNow(player: Player) -> Bool {
        return currentPlayerIndex == player.orderIndex
    }
    func currentPlayers()-> [Player] {
        return players.filter({$0.chipsRemaining > 0})
    }
    func isDealer(player: Player)->Bool {
        return player.orderIndex == dealerIndex
    }
    func isSmallBlind(player: Player)->Bool {
        if requireBigLittle {
            if (dealerIndex+1 < currentPlayers().count && player.orderIndex == dealerIndex + 1) || (dealerIndex + 1 >= currentPlayers().count && player.orderIndex == dealerIndex + 1 - currentPlayers().count) {
                return true
            }
        }
        return false
    }
    func isLargeBlind(player: Player)->Bool {
        if requireBigLittle {
            if (dealerIndex+2 < players.count && player.orderIndex == dealerIndex + 2) || (dealerIndex + 2 >= currentPlayers().count && player.orderIndex == dealerIndex + 2 - currentPlayers().count) {
                return true
            }
        }
        return false
    }
    
    func advertiseTableToPlayers() {
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    func setUpGame() {
        minBet = 2
        round = 0
        dealerIndex = -1
        var i = 0
        for player in players {
            player.orderIndex = i
            player.chipsRemaining = Int(startingChipCount) ?? 20
            i += 1
        }
        goToNextRound()
    }
    
    func goToNextRound() {
        dealerIndex += 1
        if dealerIndex == currentPlayers().count {
            dealerIndex = 0
        }
        //configure who is up and who has initail bets
        if requireBigLittle {
            currentPlayerIndex = dealerIndex + 3
            currentBetOnTable = minBet
        } else {
            currentPlayerIndex = dealerIndex + 1
        }
        if (currentPlayerIndex >= currentPlayers().count) {
            currentPlayerIndex = currentPlayerIndex-currentPlayers().count
        }
        
        //configure min bets
        for player in players {
            if isSmallBlind(player: player) {
                player.currentBet = minBet/2
                player.chipsRemaining -= player.currentBet
            }
            else if isLargeBlind(player: player) {
                player.currentBet = minBet
                player.chipsRemaining -= player.currentBet
            }else {
                player.currentBet = 0
            }
            sendData()
        }
    }
    
    func nextPlayersTurn() {
        currentPlayerIndex += 1
        if currentPlayers().count <= 1 {
            print("There is a winner!")
            return
        }
        if (currentPlayerIndex >= currentPlayers().count) {
            currentPlayerIndex = currentPlayerIndex-currentPlayers().count
        }
        if getCurrentPlayer().folded {
            nextPlayersTurn()
            return
        }
        if getCurrentPlayer().chipsRemaining <= 0 {
            nextPlayersTurn()
            return
        }
        sendData()
    }
    
    func sendData() {
        for player in players {
            player.isMyTurn = false
            if isPlayingNow(player: player) {
                player.isMyTurn = true
            }
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: .waitingPlayers, chipsRemaining: player.chipsRemaining, currentBet: player.currentBet, currentPlayer: getCurrentPlayer().name, currentBetOnTable: currentBetOnTable)
            if (currentPlayerIndex == player.orderIndex) {
                gameDataToTransfer.gameState = .yourTurn
            }
            do {
                let data = try JSONEncoder().encode(gameDataToTransfer)
                if let peerId = player.peerId {
                    try session.send(data, toPeers: [peerId], with: .unreliable)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}

enum GameState: String, CaseIterable, CustomStringConvertible, Codable {
    case waitingSetup, waitingPlayers, yourTurn, yourTurnOver, endOfRound

    var description : String {
        switch self {
        case .waitingSetup: return "waitingSetup"
        case .waitingPlayers: return "waitingPlayers"
        case .yourTurn: return "yourTurn"
        case .yourTurnOver: return "yourTurnOver"
        case .endOfRound: return "endOfRound"
        }
    }
}


extension Game: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case MCSessionState.notConnected:
            // Peer disconnected
            break
        case MCSessionState.connected:
            // Peer connected
            break
        default:
            // Peer connecting or something else
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let playerData = try JSONDecoder().decode(PlayerInfoToTransfer.self, from: data)
            DispatchQueue.main.async {
                self.players[self.currentPlayerIndex].updateFromTransfer(transfer: playerData)
                self.currentBetOnTable = playerData.currentBetOnTable ?? 0
//                self.goToNextRound()
                self.nextPlayersTurn()
            }
        }
        catch {
            print("Could not present data")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension Game: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let context = context {
            do {
                let playerData = try JSONDecoder().decode(PlayerInfoToTransfer.self, from: context)
                DispatchQueue.main.async {
                    self.players.append(Player(playerToTransfer: playerData, peerId: peerID))
                }
            }
            catch {
                print("Could not present data")
            }
        }
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}


//extension Game: MCNearbyServiceBrowserDelegate {
//    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
//        //TODO: Tell the user something went wrong and try again
//        print("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        print("ServiceBrowser found peer: \(peerID)")
//        // Add the peer to the list of available peers
//    }
//
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        print("ServiceBrowser lost peer: \(peerID)")
//        // Remove lost peer from list of available peers
//    }
//}
