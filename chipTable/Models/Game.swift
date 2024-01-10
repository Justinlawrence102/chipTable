//
//  Game.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

class Chip: ObservableObject, Identifiable{
    var color: Color
    let id = UUID().uuidString
    var x, y: Int
    
    init() {
        color = Color("Red Chip")
        x = 0
        y = 0
    }
    
    init(color: Color) {
        self.color = color
        x = Int.random(in: 0..<750)
        y = Int.random(in: 0..<350)
    }
}

class Game: NSObject, ObservableObject {
    @Published var players: [Player]
    @Published var chips: [Chip]
    @Published var name: String
    var dealerIndex: Int
    @Published var round = 0
    @Published var startConffeti = 0
    var minBet = 2
    var requireBigLittle = true
    var increaseMaxBet = true
    var startingChipCount = ""
    var currentBetOnTable = 0
    private var currentPlayerIndex: Int
    private var currentBettingLeaderIndex = 0
    private var roundJustStarted = true //used to set first player
    private var startingPlayerIndex = 0
    @Published var bettingRoundOver = false
    
    @Published var showingWinnerSelectModal = false
    
    
    //mulipeer connectivity
    private let serviceType = "chipTable-serv"
    private var myPeerID: MCPeerID
    
    public var serviceAdvertiser: MCNearbyServiceAdvertiser
    public var serviceBrowser: MCNearbyServiceBrowser
    public var session: MCSession
    
    
    override init() {
        
        players = []//[Player(name: "Justin", color: .red), Player(name: "Mark", color: .green), Player(name: "Allison", color: .yellow), Player(name: "Nicole", color: .purple)]
        chips = []
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
    func playersWithChips()-> [Player] {
        return players.filter({$0.chipsRemaining > 0})
    }
    func isDealer(player: Player)->Bool {
        return player.orderIndex == dealerIndex
    }
    
    func selectWinner(player: Player) {
        var totalChipsOnTable = 0
        for player in players {
            totalChipsOnTable += player.currentBet
        }
        players[player.orderIndex].chipsRemaining += totalChipsOnTable
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
        round += 1
        currentBetOnTable = 0
        chips = []
        
        if playersWithChips().count <= 1 {
            print("\(playersWithChips().first?.name ?? "Player") won!")
            startConffeti += 1
            sendGameOverData()
            return
        }
        
        if increaseMaxBet {
            minBet = (players.count - playersWithChips().count + 1)*2
        }else {
            minBet = 2
        }
        while(true) {
            dealerIndex += 1
            if dealerIndex == players.count {
                dealerIndex = 0
            }
            if players[dealerIndex].chipsRemaining > 0 || playersWithChips().count <= 1 {
                break
            }
        }
        //Reset min bets
        for player in players {
            player.currentBet = 0
            player.folded = false
        }
        
        var gaveLargeBlind = false
        var gaveSmallBlind = false
        var foundFirstPlayer = false
        var i = dealerIndex + 1
        
        if !requireBigLittle {
            gaveLargeBlind = true
            gaveSmallBlind = true
        }
        
        while(!gaveLargeBlind || !gaveSmallBlind || !foundFirstPlayer) {
            if (i >= players.count) {
                i = 0
            }
            if players[i].chipsRemaining > 0 {
                if !gaveSmallBlind {
                    players[i].currentBet = minBet/2
                    addChipsToTable(count: minBet/2, color: players[i].color)
                    players[i].chipsRemaining -= players[i].currentBet
                    gaveSmallBlind = true
                }else if !gaveLargeBlind{
                    players[i].currentBet = minBet
                    currentBetOnTable = minBet
                    addChipsToTable(count: minBet, color: players[i].color)
                    currentBettingLeaderIndex = i
//                    currentPlayerIndex = i + 1
                    players[i].chipsRemaining -= players[i].currentBet
                    gaveLargeBlind = true
                }else if !foundFirstPlayer {
                    foundFirstPlayer = true
                    currentPlayerIndex = i
                    startingPlayerIndex = i
                }
            }
            i += 1
        }
        sendData()
    }
    
    func nextPlayersTurn() {
        if playersWithChips().count == 0 {
            print("No one else can play")
            return
        }
//        startConffeti += 1
        currentPlayerIndex += 1

        if (currentPlayerIndex >= players.count) {
            currentPlayerIndex = currentPlayerIndex-players.count
        }
        
        //check if everyone has gone and added their bet
        if currentPlayerIndex == currentBettingLeaderIndex && !roundJustStarted {
            print("ROUND IS OVER!")
            bettingRoundOver = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.bettingRoundOver = false
                self.currentPlayerIndex = self.startingPlayerIndex - 1
                self.currentBettingLeaderIndex = self.startingPlayerIndex
                self.nextPlayersTurn()
                self.roundJustStarted = true
            }
            return
        }
        roundJustStarted = false
        
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
    func addChipsToTable(count: Int, color: Color) {
        for _ in 0..<count {
            chips.append(Chip(color: color))
        }
    }
    func sendData() {
        for player in players {
            player.isMyTurn = isPlayingNow(player: player)
//            if isPlayingNow(player: player) {
//                player.isMyTurn = true
//            }
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: .waitingPlayers, chipsRemaining: player.chipsRemaining, currentBet: player.currentBet, currentPlayer: getCurrentPlayer().name, currentBetOnTable: currentBetOnTable, color: player.getColorString())
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
    func sendGameOverData() {
        for player in players {
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: .endOfGame, chipsRemaining: player.chipsRemaining, currentBet: player.currentBet, currentPlayer: playersWithChips().first?.name ?? "Player", currentBetOnTable: currentBetOnTable, color: player.getColorString())
            if player.name == playersWithChips().first?.name {
                gameDataToTransfer.gameState = .playerWon
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
    func get2dArrayOfPlayers() -> [[Player]]? {
        var players = [[Player]]()
        var index = 1
        var smallArray = [Player]()
        for player in self.players {
            smallArray.append(player)
            if index % 3 == 0 {
                players.append(smallArray)
                smallArray = [Player]()
            }
            index += 1
        }
        if !smallArray.isEmpty {
            players.append(smallArray)
        }
        return players
    }
}

enum GameState: String, CaseIterable, CustomStringConvertible, Codable {
    case waitingSetup, waitingPlayers, yourTurn, yourTurnOver, endOfGame, playerWon

    var description : String {
        switch self {
        case .waitingSetup: return "waitingSetup"
        case .waitingPlayers: return "waitingPlayers"
        case .yourTurn: return "yourTurn"
        case .yourTurnOver: return "yourTurnOver"
        case .endOfGame: return "endOfGame"
        case .playerWon: return "playerOne"
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
            if playerData.overridePlayer ?? false { //override the player with the new peerID and refresh game
                players.first(where: {$0.name == playerData.name})?.peerId = peerID
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendData()
                }
            }
            DispatchQueue.main.async {
                if let currentBet = playerData.currentBet {
                    let previousHighestBet = self.currentBetOnTable
                    
                    let newChipsAdded = currentBet - self.players[self.currentPlayerIndex].currentBet
                    self.addChipsToTable(count: newChipsAdded, color: self.players[self.currentPlayerIndex].color)
                    
                    self.players[self.currentPlayerIndex].updateFromTransfer(transfer: playerData)
                    self.currentBetOnTable = playerData.currentBetOnTable ?? 0
                    if self.currentBetOnTable > previousHighestBet {
                        self.currentBettingLeaderIndex = self.currentPlayerIndex
                    }
    //                self.goToNextRound()
                    self.nextPlayersTurn()
                }
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
                if playerData.requestPlayerList ?? false {
                    //wait a second to connect before trying to send back the list of players
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("Sending over player list:")
                        do {
                            let gameDataToTransfer = PlayerInfoToTransfer(playerList: self.players, requestPlayerList: true)
                            let data = try JSONEncoder().encode(gameDataToTransfer)
                            try self.session.send(data, toPeers: [peerID], with: .unreliable)
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.players.append(Player(playerToTransfer: playerData, peerId: peerID))
                    }
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
