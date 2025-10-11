//
//  Game.swift
//  chipTable
//
//  Created by Justin Lawrence on 1/5/23.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

class Chip: ObservableObject, Identifiable, Hashable{
    static func == (lhs: Chip, rhs: Chip) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID().uuidString
    let player: Player
    var x, y: Int
    var startX, startY: CGFloat?
    var yOffset: CGFloat {
        let y = ((startY ?? 0.0) - CGFloat(y)*2)//*1.5 //-80
//        if y < 0 {
//            return CGFloat(y) - (startY ?? 0.0)
//        }
        return y
    }
    var xOffset: CGFloat {
        let x = ((startX ?? 0.0) - CGFloat(x)*2) //*1.5
//        if x < 0 {
//            return CGFloat(x) - (startX ?? 0.0)
//        }
        return x
    }
    
    init() {
        x = 0
        y = 0
        player = Player()
    }
    
    init(x: Int, y: Int, player: Player) {
        self.x = x
        self.y = y
        self.player = player
    }
    init(player: Player) {
        x = Int.random(in: 0..<750)
        y = Int.random(in: 0..<350)
        self.player = player
    }
    
    init(player: Player, playerPosition: CGPoint, numChipGroups: Int) {
        self.player = player
        x = Int.random(in: 0..<(750/numChipGroups))
        y = Int.random(in: 0..<(350))
        startX = playerPosition.x
        startY = playerPosition.y
    }
    func getColorString()->String {
        switch player.color {
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
}

class Game: NSObject, ObservableObject {
    @Published var players: [Player]
//    @Published var chips: [Chip]
    @Published var chipGroups: [ChipGroup]
    @Published var name: String
    @Published var dealerIndex: Int
    @Published var startingDealerId = ""
    @Published var round = 0
    @Published var startConffeti = 0
    var minBet = 2
    var requireBigLittle = true
    var increaseMaxBet = true
    var startingChipCount = ""
    var currentBetOnTable = 0
    @Published var currentPlayerIndex: Int
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
    
    
    init(withSampleData: Bool = false) {
        
        players = []
        if withSampleData {
            players = [Player(name: "Justin", color: .red), Player(name: "Mark", color: .green), Player(name: "Allison", color: .yellow), Player(name: "Nicole", color: .purple)]
        }else {
            players = []
        }
        chipGroups = []
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
    func playerIndexCanWinRound(index: Int, player: Player) -> Bool {
        if chipGroups.indices.contains(index) {
            return chipGroups[index].avaiablePlayers.contains(player) && !player.folded
        }
        return false
    }
    
    func selectWinner(player: Player, chipGroup: Int) {
//        var totalChipsOnTable = 0
//        for player in players {
//            totalChipsOnTable += player.currentBet
//        }
        players[player.orderIndex].chipsRemaining += chipGroups[chipGroup].chips.count
    }
    
    func advertiseTableToPlayers() {
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func setUpGame() {
        //set dealer to be first and order around table
        players.sort(by: {$1.sortPosition ?? 0 > $0.sortPosition ?? 0})
       
        if let _dealerIndex = players.firstIndex(where: {$0.id == startingDealerId}) {
            dealerIndex = _dealerIndex - 1 //-1 because the goToNextRound function increments it by one
        }else {
            dealerIndex = -1
        }
        minBet = 2
        round = 0
        currentPlayerIndex = 0
        var i = 0
        for player in players {
            player.orderIndex = i
            player.chipsRemaining = Int(startingChipCount) ?? 20
            i += 1
        }
        goToNextRound()
    }
    
    func sendSetTablePotionData() {
        for i in 0..<players.count {
            let gameDataToTransfer = PlayerInfoToTransfer(gameState: i == currentPlayerIndex ? .pickTablePosition : .waitingSetup, player: players[i], game: self)
            do {
                let data = try JSONEncoder().encode(gameDataToTransfer)
                if let peerId = players[i].peerId {
                    try session.send(data, toPeers: [peerId], with: .unreliable)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    func goToNextRound() {
        round += 1
        currentBetOnTable = 0
        chipGroups = [ChipGroup(chips: [], currentWager: currentBetOnTable)]

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
            player.hasPlayedThisRound = false
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
                    if players[i].chipsRemaining < minBet/2 {
                        players[i].currentBet = players[i].chipsRemaining
                    }else {
                        players[i].currentBet = minBet/2
                    }
                    addChipsToTable(_count: players[i].currentBet, player: players[i])
                    players[i].chipsRemaining -= players[i].currentBet
                    gaveSmallBlind = true
                }else if !gaveLargeBlind{
                    if players[i].chipsRemaining < minBet {
                        players[i].currentBet = players[i].chipsRemaining
                    }else {
                        players[i].currentBet = minBet
                    }
                    currentBetOnTable = minBet
                    addChipsToTable(_count: players[i].currentBet, player: players[i])
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
        sendData(newRound: true)
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
        getCurrentPlayer().hasPlayedThisRound = true
        sendData()
    }
    func addChipsToTable(_count: Int, player: Player) {
        var count = _count
        withAnimation {
            let currentBiggestGroup = chipGroups.last!
            print("Current Bet: \(getCurrentPlayer().currentBet), current wager is: \(currentBetOnTable)")
            if chipGroups.count > 1 {
                //check all of the exisiting groups and make sure the player has contributed to each and that
                if chipGroups[chipGroups.count-2].numChipsFromPlayer(player: player) != chipGroups[chipGroups.count-2].currentWager {
                    //start with the first pot and if the player hasn't contributed to those pots, add the missing chips. Stop of the second to last beause the code below handles the most recent pot
                    for index in 0...chipGroups.count-2 {
                        let previousPot = chipGroups[index]
                        if previousPot.numChipsFromPlayer(player: player) != previousPot.currentWager {
                            var chipsInPreviousPot = previousPot.currentWager - previousPot.numChipsFromPlayer(player: player)
                            print("This player needs to contibute to the previous pot first! \(previousPot.currentWager) - \(previousPot.numChipsFromPlayer(player: player)) = (\(chipsInPreviousPot))")
                            if chipsInPreviousPot > count {
                                print("The player doesn't have enough, so they will only contribute \(chipsInPreviousPot-count)")
                                chipsInPreviousPot = chipsInPreviousPot-count
                            }
                            for _ in 0..<chipsInPreviousPot {
                                chipGroups[index].chips.append(Chip(player: player, playerPosition: player.pointPosition ?? CGPoint(), numChipGroups: index+1))
                            }
                            count = count - chipsInPreviousPot
                        }
                    }
                }
            }
            var needsToSplitPot = false
            var sizeOfSmallestNewPot = Int.max
            for player in players {
                var currentBetInPot = currentBiggestGroup.numChipsFromPlayer(player: player)
                if player.isMyTurn {
                    currentBetInPot += count
                }
                if (player.currentBet+player.chipsRemaining) < currentBetOnTable && (player.hasPlayedThisRound || player.chipsRemaining == 0) &&  currentBetInPot != 0 {
                    print("\(player.name) has gone over...must split pot! \(player.currentBet) + \(player.chipsRemaining) < \(currentBetOnTable)")
                    needsToSplitPot = true
                    if currentBetInPot < sizeOfSmallestNewPot {
                        sizeOfSmallestNewPot = currentBetInPot
                    }
                }
            }
            if needsToSplitPot && count != 0 {
                print("This bet doesn't fit into this pot...make a new one!!!")

                //the player is putting less than what's on the table. Reshuffle chip groups
                let newPot = ChipGroup(chips: [], currentWager: currentBetOnTable)
                let existingPot = ChipGroup(chips: [], currentWager: currentBetOnTable)

                
                for player in players {
                    var numChipsWageredByCurrentPlayer = currentBiggestGroup.numChipsFromPlayer(player: player)
                    if player.isMyTurn {
                        numChipsWageredByCurrentPlayer += count
                    }
                    print("player: \(player.name) (\(player.isMyTurn))")
                    print("numChipsWageredByCurrentPlayer: \(numChipsWageredByCurrentPlayer)")
                    print("Size of smallest new pot: \(sizeOfSmallestNewPot)")
                    
                    if numChipsWageredByCurrentPlayer > sizeOfSmallestNewPot {
                        print("\(player.name) needs to put \(sizeOfSmallestNewPot) in existing pot and \(numChipsWageredByCurrentPlayer-sizeOfSmallestNewPot) into the new pot")
                        for _ in 0..<sizeOfSmallestNewPot {
                            existingPot.chips.append(Chip(player: player, playerPosition: player.pointPosition ?? CGPoint(), numChipGroups: chipGroups.count+1))
                        }
                        for _ in 0..<(numChipsWageredByCurrentPlayer-sizeOfSmallestNewPot) {
                            newPot.chips.append(Chip(player: player, playerPosition: player.pointPosition ?? CGPoint(), numChipGroups: chipGroups.count+1))
                        }
                    }else {
                        print("\(player.name) needs to put \(numChipsWageredByCurrentPlayer) into existing pot. They will put 0 in the new pot")
                        for _ in 0..<numChipsWageredByCurrentPlayer {
                            existingPot.chips.append(Chip(player: player, playerPosition: player.pointPosition ?? CGPoint(), numChipGroups: chipGroups.count+1))
                        }
                    }
                }
                chipGroups.last?.chips = existingPot.chips
                chipGroups.last?.currentWager = sizeOfSmallestNewPot
                newPot.currentWager = currentBetOnTable
                chipGroups.append(newPot)
            }else {
                //currentWager
                for _ in 0..<count {
                    chipGroups.last?.chips.append(Chip(player: player, playerPosition: player.pointPosition ?? CGPoint(), numChipGroups: chipGroups.count))
                    chipGroups.last?.currentWager = currentBetOnTable
                }
            }
        }
    }
    
    func adChipsToGroup(chipsRemaining: Int) {
        if chipsRemaining == 0 {
            return //base case
        }
        
    }
    func sendNewGameState(state: GameState) {
        for player in players {
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: state, player: player, game: self)
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
    
    func sendData(newRound: Bool = false) {
        for player in players {
            player.isMyTurn = isPlayingNow(player: player)
//            if isPlayingNow(player: player) {
//                player.isMyTurn = true
//            }
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: .waitingPlayers, player: player, game: self)
            if (newRound && player.currentBet != 0) {
                gameDataToTransfer.gameState = .sentBlind
            }
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
            var gameDataToTransfer = PlayerInfoToTransfer(gameState: .endOfGame, player: player, game: self)
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
    case waitingSetup, waitingPlayers, yourTurn, endOfGame, playerWon, pickTablePosition, endOfRoundSummary, sentBlind

    var description : String {
        switch self {
        case .waitingSetup: return "waitingSetup"
        case .waitingPlayers: return "waitingPlayers"
        case .yourTurn: return "yourTurn"
        case .endOfGame: return "endOfGame"
        case .playerWon: return "playerOne"
        case .pickTablePosition: return "pickTablePosition"
        case .endOfRoundSummary: return "endOfRoundSummary"
        case .sentBlind: return "Sent Blind"
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
                    
                    var newChipsAdded = currentBet - self.players[self.currentPlayerIndex].currentBet
                    if playerData.folded ?? false {
                        newChipsAdded = 0
                    }
                    self.players[self.currentPlayerIndex].updateFromTransfer(transfer: playerData)
                    
//                  only set the current bet on table if its going to be larger...not if someone needs to split the pot
                    if playerData.currentBetOnTable ?? 0 > self.currentBetOnTable {
                        self.currentBetOnTable = playerData.currentBetOnTable ?? 0
                    }
                    
                    if self.currentBetOnTable > previousHighestBet {
                        self.currentBettingLeaderIndex = self.currentPlayerIndex
                        for player in self.players {
                            player.hasPlayedThisRound = false
                        }
                    }
                    
                    self.addChipsToTable(_count: newChipsAdded, player: self.players[self.currentPlayerIndex])
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
                }else if round == 0 {
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

class ChipGroup: ObservableObject, Identifiable{
    let id = UUID()
    var avaiablePlayers: [Player] {
        return Array(Set(chips.map({$0.player})))
    }
    var currentWager: Int
    @Published var chips: [Chip]
    
    init(chips: [Chip], currentWager: Int) {
        self.chips = chips
        self.currentWager = currentWager
    }
    
    func numChipsFromPlayer(player: Player) -> Int {
        return chips.filter({$0.player.id == player.id}).count
    }
}
