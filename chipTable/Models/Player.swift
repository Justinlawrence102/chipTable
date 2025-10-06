//
//  Player.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

class Player: NSObject, ObservableObject, Identifiable {
    @Published var name: String
    let id = UUID().uuidString
    var peerId: MCPeerID?
    @Published var currentBet: Int
    @Published  var isMyTurn = false
    var folded = false
    @Published var chipsRemaining: Int
    var hasPlayedThisRound = false
    var orderIndex = 0
    
    var pointPosition: CGPoint? = nil
    var sortPosition: Int? = nil

    
    var chips = [Chip]()

    @Published var color: Color
    
    override init() {
        name = ""
        peerId = nil
        currentBet = 0
        chipsRemaining = 0
        color = Color("Chip Red")
        
        super.init()
    }
    init(playerToTransfer: PlayerInfoToTransfer, peerId: MCPeerID? = nil) {
        name = playerToTransfer.name ?? ""
        color = playerToTransfer.getColor()
        self.peerId = peerId
        self.currentBet = playerToTransfer.currentBet ?? 0
        self.chipsRemaining = playerToTransfer.chipsRemaining ?? 0
    }
    
    init(name: String, color: Color, peerId: MCPeerID) {
        self.name = name
        self.peerId = peerId
        self.color = color
        self.currentBet = 0
        self.chipsRemaining = 0
    }
    init(name: String, color: Color) {
        self.name = name
        self.peerId = nil
        self.color = color
        self.currentBet = 0
        self.chipsRemaining = 0
    }
    func updateFromTransfer(transfer: PlayerInfoToTransfer) {
        self.chipsRemaining = transfer.chipsRemaining ?? 0
        self.currentBet = transfer.currentBet ?? 0
        self.folded = transfer.folded ?? false
    }
    func getColorString()->String {
        switch color {
        case Color("Chip Red"):
            return "Chip Red"
        case Color("Chip Blue"):
            return "Chip Blue"
        case Color("Chip Green"):
            return "Chip Green"
        case Color("Chip Black"):
            return "Chip Black"
        case Color("Chip Purple"):
            return "Chip Purple"
        case Color("Chip Orange"):
            return "Chip Orange"
        default:
            return "Chip Red"
        }
    }
    func getColorString(color: Color)->String {
        switch color {
        case Color("Chip Red"):
            return "Chip Red"
        case Color("Chip Blue"):
            return "Chip Blue"
        case Color("Chip Green"):
            return "Chip Green"
        case Color("Chip Black"):
            return "Chip Black"
        case Color("Chip Purple"):
            return "Chip Purple"
        case Color("Chip Orange"):
            return "Chip Orange"
        default:
            return "Chip Red"
        }
    }
    
    func getColorOptions() -> [Color] {
        return [Color("Chip Red"), Color("Chip Blue"), Color("Chip Green"), Color("Chip Black"), Color("Chip Orange"), Color("Chip Purple")]
    }
}
struct PlayerInfoToTransfer: Codable {
    var name: String?
    var color: String?
    var folded: Bool?
    var chipsRemaining, currentBet: Int?
    var gameState: GameState?
    var currentPlaterName: String?
    var currentBetOnTable: Int?
    var roundNumber: Int?
    
    var requestPlayerList: Bool?
    var playerList: [String]?
    var playerChipsWageredList: [Int]?
    var playerChipsRemainingList: [Int]?
    var chipsOnTable: [String]?
    var overridePlayer: Bool? //when this is true, the peerID of the sender will replace what is saved for the player name
    init() {
    
    }
    init(requestPlayerList: Bool) {
        self.requestPlayerList = requestPlayerList
    }
    init(overridePlayer: Bool, playerName: String) {
        name = playerName
        self.overridePlayer = overridePlayer
    }
    init(player: Player) {
        name = player.name
        color = player.getColorString()
        folded = player.folded
        currentBet = player.currentBet
        chipsRemaining = player.chipsRemaining
    }
    init(playerList: [Player], requestPlayerList: Bool) {
        self.playerList = playerList.map({$0.name})
        self.requestPlayerList = requestPlayerList
    }
    
    init(gameState: GameState, player: Player, game: Game) {
        self.gameState = gameState
        self.chipsRemaining = player.chipsRemaining
        self.currentBet = player.currentBet
        self.currentPlaterName = game.getCurrentPlayer().name
        self.currentBetOnTable = game.currentBetOnTable
        self.color = player.getColorString()
        self.playerList = game.players.map({$0.name})
        self.roundNumber = game.round
        self.playerChipsWageredList = game.players.map({$0.currentBet})
        self.playerChipsRemainingList = game.players.map({$0.chipsRemaining})
        self.chipsOnTable = game.chipGroups.first?.chips.map({"\($0.x),\($0.y),\($0.getColorString())"})
        if gameState == .endOfGame {
            self.currentPlaterName = game.playersWithChips().first?.name
        }
    }
    
    func getColor()->Color {
        return Color(color ?? "Chip Red")
    }
}

class PlayerGame: NSObject, ObservableObject {
    
    @Published var player: Player
    @Published var availableGames = [MCPeerID]()
    @Published var currentPlayer = ""
    @Published var currentBetOnTable = 0
    var gameState: GameState
    
    @Published var isYourTurn = false
    
    @Published var playersChips = [[Chip]]()
    @Published var rowCounter = 0
    
    //list of players for when we disconnect or for visionOS
    @Published var players: [String]?
    var playerChipsWageredList: [Int]?
    var playerChipsRemainingList: [Int]?
    @Published var roundNumber: Int?
    var chipsOnTable: [String]?
    var chipsOnTableDecoded: [Chip] {
        var chipList = [Chip]()
        for chip in chipsOnTable ?? [] {
            let comp = chip.components(separatedBy: ",")
            if comp.indices.contains(2) {
//                let test = Color(comp[2])
                chipList.append(Chip(x: Int(comp[0]) ?? 0, y: Int(comp[1]) ?? 0, player: Player(name: "", color: Color(comp[2]))))
            }
        }
        return chipList
    }
    var initalChipsBet = 0
    
    //mulipeer connectivity
    private let serviceType = "chipTable-serv"
    private var myPeerID: MCPeerID
    private var tablePeerId: MCPeerID
    
    public var serviceAdvertiser: MCNearbyServiceAdvertiser
    public var serviceBrowser: MCNearbyServiceBrowser
    public var session: MCSession
    
    
    override init() {
        player = Player()
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        gameState = .waitingSetup
        
        tablePeerId = myPeerID //this is replaced when you select a table
        super.init()
        
        browsForTables()
        
        setUpChipsUI()
    }
    init(player: Player) {
        self.player = player
        self.initalChipsBet = player.currentBet
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        gameState = .waitingSetup
        
        tablePeerId = myPeerID //this is replaced when you select a table 
        super.init()
        
        browsForTables()
        
        setUpChipsUI()
//        players = ["Justin", "mark", "Allison"]
//        currentPlayer = "mark"
    }
    init(gameStatePreviews: GameState) {
        self.player = Player()
        gameState = gameStatePreviews
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        tablePeerId = myPeerID //this is replaced when you select a table
        super.init()
    }
    
    func addPlayer(player: Player){
        self.player = player
    }
    
    func getChipsForPlayer(player: String) ->String {
        if let index = players?.lastIndex(where: {$0 == player}) {
            if (playerChipsWageredList ?? []).indices.contains(index) {
                return String((playerChipsWageredList  ?? [])[index])
            }
        }
        return "0"
    }
    func getChipsRemainingForPlayer(player: String) -> Int {
        if let index = players?.lastIndex(where: {$0 == player}) {
            if (playerChipsRemainingList ?? []).indices.contains(index) {
                return (playerChipsRemainingList  ?? [])[index]
            }
        }
        return 0
    }
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }

    func matchBet() {
        if player.chipsRemaining + (player.currentBet - currentBetOnTable) < 0 {
            //going all in
            player.currentBet = player.currentBet + player.chipsRemaining
            player.chipsRemaining = 0
            return
        }
        if player.currentBet < currentBetOnTable {
            player.chipsRemaining = player.chipsRemaining + (player.currentBet - currentBetOnTable)
            player.currentBet = currentBetOnTable
        }
    }
    func raise1() {
        if (player.chipsRemaining + (player.currentBet - currentBetOnTable) - 1 < 0) || player.chipsRemaining - 1 < 0 {
            return
        }
        if player.currentBet < currentBetOnTable {
            player.chipsRemaining = player.chipsRemaining + (player.currentBet - currentBetOnTable) - 1
            player.currentBet = currentBetOnTable + 1
        } else {
            player.currentBet = player.currentBet + 1
            player.chipsRemaining = player.chipsRemaining - 1
        }
    }
    func goAllIn() {
        player.currentBet = player.currentBet + player.chipsRemaining
        player.chipsRemaining = 0
        sendChips()
    }
    
    func sendChips() {
        setUpChipsUI()
        do {
            if player.currentBet >= currentBetOnTable || player.folded || (player.currentBet < currentBetOnTable && player.chipsRemaining == 0){
                if !player.folded {
                    currentBetOnTable = player.currentBet
                }
                var transfer = PlayerInfoToTransfer(player: player)
                transfer.currentBetOnTable = currentBetOnTable
                let player = try JSONEncoder().encode(transfer)
                try session.send(player, toPeers: [tablePeerId], with: .unreliable)
                isYourTurn = false
            }
        }
        catch {
            print("Couldnt send data!")
        }
    }
    func setUpChipsUI() {
        playersChips.removeAll()
        rowCounter = -1
        for i in 0..<player.chipsRemaining {
            if i%10 == 0 {
                playersChips.append([Chip(player: player)])
                rowCounter += 1
            }else {
                playersChips[rowCounter].append(Chip(player: player))
            }
        }
    }
    func getRowCount()->Int {
        if player.chipsRemaining%10 == 0 {
            return player.chipsRemaining/10
        }
        return (player.chipsRemaining/10) + 1
    }
    func fold() {
        player.folded = true
        let chipsBetThisRound = player.currentBet - initalChipsBet
        player.currentBet -= chipsBetThisRound
        player.chipsRemaining += chipsBetThisRound
        sendChips()
    }
    
    func browsForTables() {
        session.delegate = self
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
//        serviceAdvertiser.delegate = self
//        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func didSelectGame(gameId: MCPeerID) {
        do {
            let player = try JSONEncoder().encode(PlayerInfoToTransfer(player: player))
            serviceBrowser.invitePeer(gameId, to: session, withContext: player, timeout: TimeInterval(120))
            tablePeerId = gameId
        }
        catch {
            print("Couldnt send data!")
        }
    }
    func requestPlayerList(gameId: MCPeerID) {
        tablePeerId = gameId
        do {
            let transfer = PlayerInfoToTransfer(requestPlayerList: true)
            let playerRequest = try JSONEncoder().encode(transfer)
            serviceBrowser.invitePeer(gameId, to: session, withContext: playerRequest, timeout: TimeInterval(120))
//            try session.send(playerRequest, toPeers: [tablePeerId], with: .unreliable)
        }
        catch {
            print("Couldnt send data!")
        }
    }
    func rejoinGame(player: String) {
        do {
            let transfer = PlayerInfoToTransfer(overridePlayer: true, playerName: player)
            let playerRequest = try JSONEncoder().encode(transfer)
            try session.send(playerRequest, toPeers: [tablePeerId], with: .unreliable)
        }
        catch {
            print("Couldnt send data!")
        }
    }
}
extension PlayerGame: MCSessionDelegate {
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
        print("IS Receiving data!")
        do {
            let playerData = try JSONDecoder().decode(PlayerInfoToTransfer.self, from: data)
            if playerData.requestPlayerList ?? false {
                print("Received player list!")
                print(playerData.playerList ?? [])
                players = playerData.playerList
            }
            DispatchQueue.main.async {
                self.player = Player(playerToTransfer: playerData)
                self.gameState = playerData.gameState ?? .waitingPlayers
                self.currentPlayer = playerData.currentPlaterName ?? ""
                self.currentBetOnTable = playerData.currentBetOnTable ?? 0
                self.players = playerData.playerList
                self.playerChipsWageredList = playerData.playerChipsWageredList
                self.playerChipsRemainingList = playerData.playerChipsRemainingList
                self.roundNumber = playerData.roundNumber
                self.chipsOnTable = playerData.chipsOnTable
                self.initalChipsBet = playerData.currentBet ?? 0
                if self.gameState == .yourTurn {
                    self.isYourTurn = true
                } else {
                    self.isYourTurn = false
                }
                print("Chips Remaining! \(self.player.chipsRemaining)")
                print("State? \(self.gameState)")
                self.setUpChipsUI()
            }
        }
        catch {
            print("Could not present data")
        }
        //        if let string = String(data: data, encoding: .utf8), let move = Move(rawValue: string) {
        //            // Received move from peer
        //        } else {
        //            print("didReceive invalid value \(data.count) bytes")
        //        }
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

extension PlayerGame: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("ServiceBrowser found peer: \(peerID)")
        if !availableGames.contains(where: {$0.displayName == peerID.displayName}) {
            availableGames.append(peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("ServiceBrowser lost peer: \(peerID)")
        availableGames.removeAll(where: {$0.displayName == peerID.displayName})
    }
}
